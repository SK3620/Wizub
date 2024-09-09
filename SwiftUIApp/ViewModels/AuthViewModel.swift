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
    }
    
    // MARK: - Inputs
    @Published var userName: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    
    // MARK: - Outputs
    @Published var segmentType: SegmentType = .signInSegment
    
    @Published var isLoading: Bool = false
    @Published var isSuccess: Bool = false
    @Published var isShowError: Bool = false
    @Published var httpErrorMsg: String = ""
            
    @Published var userNameError: String = ""
    @Published var emailError: String = ""
    @Published var passwordError: String = ""
    
    @Published var enableSignUp: Bool = false
    @Published var enableSignIn: Bool = false
                
    func apply(taps: AuthButtonTaps) {
        isLoading = true
        isSuccess = false
        // 非同期処理中は、SignUp/SignInボタン非活性
        enableSignUp = false
        enableSignIn = false
        switch taps {
        case .signUp:
            self.signUp()
        case .signIn:
            self.signIn()
        }
    }
    
    // MARK: - private
    private let apiService: APIServiceType
    private let keyChainManager: KeyChainManager = KeyChainManager()
    private let httpErrorSubject = PassthroughSubject<HttpError, Never>()
    private var cancellableBag = Set<AnyCancellable>()
    
    // MARK: - AnyPublisher
    private var usernameValidPublisher: AnyPublisher<InputValidation, Never> {
        return $userName
            .map {
                let error = InputValidation.self
                return $0.isEmpty ? error.missingUsername : error.noError
            }
            .eraseToAnyPublisher()
    }
    
    private var emailValidPublisher: AnyPublisher<(email: String, error: InputValidation), Never> {
        return $email
        // SignIn/SignUpセグメントの切り替え時、$segmentTyepを発火
            .combineLatest($segmentType)
            .map { email, segmentType in
                let error = InputValidation.self
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
    
    private var emailServerValidPublisher: AnyPublisher<InputValidation, Never> {
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
                let error = InputValidation.self
                return !$0 ? error.noError : error.emailAlreadyUsed
            }
            .eraseToAnyPublisher()
    }
    
    private var passwordValidPublisher: AnyPublisher<InputValidation, Never> {
        return $password
            .map {
                let error = InputValidation.self
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
                return $0
            }
            .eraseToAnyPublisher()
    }
    
    // MARK: - init
    init(apiService: APIServiceType) {
        
        self.apiService = apiService
        
        self.email = keyChainManager.loadCredentials(service: .emailService)
        self.password = keyChainManager.loadCredentials(service: .passwordService)
        
        usernameValidPublisher
            .receive(on: RunLoop.main)
            .dropFirst()
            .map { $0.errorDescription }
            .assign(to: \.userNameError, on: self)
            .store(in: &cancellableBag)
        
        emailValidPublisher
            .receive(on: RunLoop.main)
            .dropFirst()
            .map { $0.error.errorDescription }
            .assign(to: \.emailError, on: self)
            .store(in: &cancellableBag)
        
        emailServerValidPublisher
            .receive(on: RunLoop.main)
            .dropFirst()
            .map { [weak self] (error) in
                guard let self = self else { return "" }
                // 重複チェックはサインアップ時のみ適用
                return (error == .emailAlreadyUsed && self.segmentType == .signInSegment) ? "" : error.errorDescription
            }
            .assign(to: \.emailError, on: self)
            .store(in: &cancellableBag)

        passwordValidPublisher
            .receive(on: RunLoop.main)
            .dropFirst()
            .map { $0.errorDescription }
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
                // 全てのバリデーション結果が.noErrorの場合、認証ボタンを活性化する
            case .signUpSegment:
                self.enableSignUp = [userNameValidation, emailValidation.error, emailServerValidation, passwordValidation].allSatisfy { $0 == .noError }
            case .signInSegment:
                self.enableSignIn = [emailValidation.error, passwordValidation].allSatisfy { $0 == .noError }
            }
        }
        .store(in: &cancellableBag)
        
        httpErrorSubject
            .sink(receiveValue: { [weak self] (error) in
                guard let self = self else { return }
                self.isLoading = false
                self.isSuccess = false
                self.isShowError = true
                self.httpErrorMsg = error.localizedDescription
                self.enableSignUp = true
                self.enableSignIn = true
            })
            .store(in: &cancellableBag)
    }
    
    deinit {
        cancellableBag.removeAll()
    }
}

// MARK: - HTTPリクエスト＆レスポンスハンドリング
extension AuthViewModel {
    
    // サインアップ/サインイン
    private func authenticate(with request: any CommonHttpRouter, authModel: AuthModel) {
        apiService.request(with: request)
            .receive(on: RunLoop.main)
            .catch { [weak self] (error) -> Empty<Decodable, Never> in
                // 上流Publisherのエラーをcatch 別のPublisherへエラーを流す
                self?.httpErrorSubject.send(error)
                // 空のPublisherに置き換えストリームを中断
                return .init()
            }
            .sink(receiveValue: { [weak self] value in
                guard let self = self, let value = AuthModel.handleResponse(value: value) else { return }
                self.isLoading = false
                self.isSuccess = true
                self.enableSignUp = true
                self.enableSignIn = true
                // 認証情報をキーチェーンへ保存
                self.keyChainManager.saveCredentials(apiToken: value.apiToken, email: value.email, password: value.password)
            })
            .store(in: &cancellableBag)
    }
    
    // サインアップ
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

    // サインイン
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
                guard let value = AuthModel.handleResponse(value: $0) else { return false }
                return value.isDuplicatedEmail!
            }
            .catch {
                print($0.localizedDescription)
                return Just(false)
            }
            .eraseToAnyPublisher()
    }
}
