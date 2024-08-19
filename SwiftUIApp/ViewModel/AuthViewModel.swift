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
    @Published var usernameError: String = ""
    
    @Published var email: String = ""
    @Published var emailError: String = ""
    
    @Published var password: String = ""
    @Published var passwordError: String = ""
    
    @Published var enableSignUp: Bool = false
    @Published var enableSignIn: Bool = false
    
    func apply(taps: AuthButtonTaps) {
        switch taps {
        case .signUp:
            self.signUp()
        case .signIn:
            print("signIn")
        case .forgetPassword:
            print("forget your password")
        }
    }
    
    private var usernameValidPublisher: AnyPublisher<ErrorMessages, Never> {
        return $userName
            .map {
               !$0.isEmpty ? ErrorMessages.noError : ErrorMessages.missingUsername
            }
            .eraseToAnyPublisher()
    }
    
    private var emailValidPublisher: AnyPublisher<ErrorMessages, Never> {
        return $email
            .map {
                switch true {
                case $0.isEmpty:
                    return ErrorMessages.missingEmail
                case !$0.isValidEmail():
                    return ErrorMessages.invalidEmail
                default:
                    return ErrorMessages.noError
                }
            }
            .eraseToAnyPublisher()
    }
    
    private var passwordValidPublisher: AnyPublisher<ErrorMessages, Never> {
        return $password
            .map {
                switch true {
                case $0.isEmpty:
                    return ErrorMessages.missingPassword
                case !$0.isValidPassword():
                    return ErrorMessages.invalidPassword
                default:
                    return ErrorMessages.noError
                }
            }
            .eraseToAnyPublisher()
    }
    
    private var segmentOnChangedPublisher: AnyPublisher<SegmentType, Never> {
        return $segmentType
            .map { $0 }
            .eraseToAnyPublisher()
    }
                                                        
    
    init(apiService: APIServiceType) {
        
        self.apiService = apiService
        
        usernameValidPublisher
            .receive(on: RunLoop.main)
            .dropFirst()
            .map { return $0.rawValue }
            .assign(to: \.usernameError, on: self)
            .store(in: &cancellableBag)
        
        emailValidPublisher
            .receive(on: RunLoop.main)
            .dropFirst()
            .map { $0.rawValue }
            .assign(to: \.emailError, on: self)
            .store(in: &cancellableBag)
        
        passwordValidPublisher
            .receive(on: RunLoop.main)
            .dropFirst()
            .map { return $0.rawValue }
            .assign(to: \.passwordError, on: self)
            .store(in: &cancellableBag)
        
        Publishers.CombineLatest4(segmentOnChangedPublisher, usernameValidPublisher, emailValidPublisher, passwordValidPublisher)
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
                    self.statusViewModel = StatusViewModel(isLoading: false, showErrorMessage: false, alertErrorMessage: "", shouldShowNextScreen: true)
                    // SignUp/SignInボタンの活性化
                    self.enableSignUp = true
                    self.enableSignIn = true
                    break
                case .failure(let error):
                    // エラーアラート表示
                    self.statusViewModel = StatusViewModel(isLoading: false, showErrorMessage: true, alertErrorMessage: error.localizedDescription, shouldShowNextScreen: false)
                    // SignUp/SignInボタンの活性化
                    self.enableSignUp = true
                    self.enableSignIn = true
                }
            }, receiveValue: { [weak self] value in
                guard let self = self, let value = authModel.handleResponse(value: value) else { return }
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
                guard let value = authModel.handleResponse(value: $0) else {
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
