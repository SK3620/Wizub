//
//  AuthViewModel.swift
//  SwiftUIApp
//
//  Created by 鈴木 健太 on 2024/08/11.
//

import Foundation
import Combine

class AuthViewModel: ObservableObject {
    
    // MARK: - Tapped
    enum AuthButtonTaps {
        // サインアップ
        case signUp
        //　サインイン
        case signIn
        // パスワード忘れた
        case forgetPassword
    }
    
    private let apiService: APIServiceType
        
    private var cancellableBag = Set<AnyCancellable>()
    
    @Published var segmentType: SegmentType = .signInSegment
        
    @Published var userName: String = ""
    @Published var userNameError: String = ""
    
    @Published var email: String = ""
    @Published var emailError: String = ""
    
    @Published var password: String = ""
    @Published var passwordError: String = ""
    
    @Published var enableSignUp: Bool = false
    @Published var enableSignIn: Bool = false
    
    @Published var statusViewModel: StatusViewModel = StatusViewModel()
    
    private let keyChainManager: KeyChainManager = KeyChainManager()
    
    func apply(taps: AuthButtonTaps) {
        // ローディング中はSignUp/SignInボタン非活性
        enableSignUp = false
        enableSignIn = false
        switch taps {
        case .signUp:
            self.signUp()
        case .signIn:
            self.signIn()
        case .forgetPassword:
            self.forgetPassword()
        }
    }
    
    private var usernameValidPublisher: AnyPublisher<MyAppError.InputValidation, Never> {
        return $userName
            .map {
                let error = MyAppError.InputValidation.self
                return $0.isEmpty ? error.missingUsername : error.noError
            }
            .eraseToAnyPublisher()
    }
    
    private var emailValidPublisher: AnyPublisher<(email: String, error: MyAppError.InputValidation), Never> {
        return $email
        // SignIn/SignUpセグメントの切り替え時、以下Publisherを発火
            .combineLatest($segmentType)
            .map { email, segmentType in
                let error = MyAppError.InputValidation.self
                switch true {
                case email.isEmpty:
                    return (email: email, error: error.missingEmail)
                case !email.isValidEmail():
                    return (email: email, error: error.invalidEmail)
                default:
                    return (email: email, error: error.noError)
                }
            }
            .eraseToAnyPublisher()
    }
    
    private var emailServerValidPublisher: AnyPublisher<MyAppError.InputValidation, Never> {
        return emailValidPublisher
            .filter {
                return $0.error == .noError
            }
            .flatMap { [weak self] (value) in
                guard let self = self else {
                    return Empty<Bool, Never>(completeImmediately: true).eraseToAnyPublisher()
                }
                return self.checkEmail(email: value.email)
            }
            .map {
                let error = MyAppError.InputValidation.self
                return !$0 ? error.noError : error.emailAlreadyUsed
            }
            .eraseToAnyPublisher()
    }
    
    private var passwordValidPublisher: AnyPublisher<MyAppError.InputValidation, Never> {
        return $password
            .map {
                let error = MyAppError.InputValidation.self
                switch true {
                case $0.isEmpty:
                    return error.missingPassword
                case !$0.isValidPassword():
                    return error.invalidPassword
                default:
                    return error.noError
                }
            }
            .eraseToAnyPublisher()
    }
    
    private var segmentOnChangedPublisher: AnyPublisher<SegmentType, Never> {
        return $segmentType
            .map {
                return  $0
            }
            .eraseToAnyPublisher()
    }
    
    init(apiService: APIServiceType) {
        
        self.apiService = apiService
        
        self.email = keyChainManager.loadCredentials(service: .emailService)
        self.password = keyChainManager.loadCredentials(service: .passwordService)
        
        usernameValidPublisher
            .receive(on: RunLoop.main)
            .dropFirst()
            .map { $0.rawValue }
            .assign(to: \.userNameError, on: self)
            .store(in: &cancellableBag)
        
        emailValidPublisher
            .receive(on: RunLoop.main)
            .dropFirst()
            .map { $0.error.rawValue }
            .assign(to: \.emailError, on: self)
            .store(in: &cancellableBag)
        
        emailServerValidPublisher
            .receive(on: RunLoop.main)
            .dropFirst()
            .map { [weak self] (error) in
                guard let self = self else { return "" }
                return (error == .emailAlreadyUsed && self.segmentType == .signInSegment) ? "" : error.rawValue
            }
            .assign(to: \.emailError, on: self)
            .store(in: &cancellableBag)

        passwordValidPublisher
            .receive(on: RunLoop.main)
            .dropFirst()
            .map { $0.rawValue }
            .assign(to: \.passwordError, on: self)
            .store(in: &cancellableBag)
        
        Publishers.CombineLatest(
            Publishers.CombineLatest4( usernameValidPublisher, emailValidPublisher, emailServerValidPublisher, passwordValidPublisher),
            segmentOnChangedPublisher // 5つ目のPublisherを追加
        )
        .receive(on: RunLoop.main)
        .sink { [weak self] combinedResult, segmentType in
            guard let self = self else { return }
            let (userNameValidation, emailValidation, emailServerValidation, passwordValidation) = combinedResult
            
            switch segmentType {
            case .signUpSegment:
                self.enableSignUp = [userNameValidation, emailValidation.error, emailServerValidation, passwordValidation].allSatisfy { $0 == .noError }
            case .signInSegment:
                self.enableSignIn = [emailValidation.error, passwordValidation].allSatisfy { $0 == .noError }
            }
        }
        .store(in: &cancellableBag)
    }
    
    deinit {
        cancellableBag.removeAll()
    }
}

extension AuthViewModel {
    
    private func authenticate(with request: any CommonHttpRouter, authModel: AuthModel) {
        // リクエスト
        apiService.request(with: request)
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { [weak self] completion in
                guard let self = self else { return }
                switch completion {
                case .finished:
                    // ローディングアイコン表示終了
                    self.statusViewModel = StatusViewModel(shouldTransition: true)
                    // SignUp/SignInボタンの活性化
                    self.enableSignUp = true
                    self.enableSignIn = true
                    break
                case .failure(let error):
                    // エラーアラート表示
                    self.statusViewModel = StatusViewModel(showErrorMessage: true, alertErrorMessage: error.localizedDescription)
                    // SignUp/SignInボタンの活性化
                    self.enableSignUp = true
                    self.enableSignIn = true
                }
            }, receiveValue: { [weak self] value in
                guard let self = self, let value = AuthModel.handleResponse(value: value) else { return }
                // 認証情報をキーチェーンへ保存
                self.keyChainManager.saveCredentials(apiToken: value.apiToken, email: value.email, password: value.password)
            })
            .store(in: &cancellableBag)
    }
    
    private func signUp() {
        let authModel = AuthModel(
            name: userName,
            email: email,
            password: password,
            apiToken: "",
            isDuplicatedEmail: nil
        )
        // サインアップリクエスト組み立て
        let signUpRequest = SignUpRequest(model: authModel)
        authenticate(with: signUpRequest, authModel: authModel)
    }

    private func signIn() {
        let authModel = AuthModel(
            name: "",
            email: email,
            password: password,
            apiToken: "",
            isDuplicatedEmail: nil
        )
        // サインインリクエスト組み立て
        let signInRequest = SignInRequest(model: authModel)
        authenticate(with: signInRequest, authModel: authModel)
    }
    
    // Emailの重複チェック
    private func checkEmail(email: String) -> AnyPublisher<Bool, Never> {
        let authModel = AuthModel(
            name: "",
            email: email,
            password: "",
            apiToken: "",
            isDuplicatedEmail: nil
        )
        // Email重複チェックリクエスト組み立て
        let checkEmailRequest = CheckEmailRequest(model: authModel)
        
        return apiService.request(with: checkEmailRequest)
            .receive(on: RunLoop.main)
            .map {
                guard let value = AuthModel.handleResponse(value: $0) else {
                    return false
                }
                return value.isDuplicatedEmail!
            }
            .catch {
                print($0.localizedDescription)
                return Just(false)
            }
            .eraseToAnyPublisher()
    }
    
    private func forgetPassword() -> Void {
        
    }
}
