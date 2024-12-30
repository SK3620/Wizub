//
//  AuthViewModel.swift
//  SwiftUIApp
//
//  Created by 鈴木 健太 on 2024/08/11.
//

import Foundation
import Combine
import SwiftUI

enum AuthSegmentType: CommonSegmentTypeProtocol {
    
    // サインインのセグメント
    case signInSegment
    // サインアップのセグメント
    case signUpSegment
    
    // 自身のインスタンスを識別子とする
    var id: Self {
        return self
    }

    var title: String {
        switch self {
        case .signInSegment:
            return "Sign In"
        case .signUpSegment:
            return "Sign Up"
        }
    }
    
    var tintColor: Color {
        return ColorCodes.buttonBackground.color()
    }
}

// MARK: - Kinds of success Enum
enum AuthSuccessStatus {
    case signedUpIn // サインアップ/サインイン成功
    case accountDeleted // アカウント削除成功
    
    // サインアップ/サインイン成功時に画面遷移
    var shouldNavigate: Bool { self == .signedUpIn }
        
    var toSuccessMsg: String {
        switch self {
        case .signedUpIn:
            return ""
        case .accountDeleted:
            return "アカウントを削除しました"
        }
    }
}

// MARK: - Alert Type
enum AlertType: Identifiable {
    case error
    case deleteAccount
    var id: AlertType { self }
}

class AuthViewModel: ObservableObject {
    
    // MARK: - Tapped
    enum AuthButtonTaps {
        // お試し利用
        case trialUse
        // サインアップ
        case signUp
        //　サインイン
        case signIn
        // アカウント削除
        case deleteAccount
    }
    
    // MARK: - Inputs
    @Published var userName: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    
    // MARK: - Outputs
    @Published var showTermsAndConditions: Bool = true
    
    @Published var authSegmentType: AuthSegmentType = .signInSegment
    
    @Published var isLoading: Bool = false
    @Published var successStatus: AuthSuccessStatus?
    @Published var myAppErrorMsg: String = ""
    @Published var alertType: AlertType?
            
    @Published var userNameError: String = ""
    @Published var emailError: String = ""
    @Published var passwordError: String = ""
    
    @Published var enableSignUp: Bool = false
    @Published var enableSignIn: Bool = false
    @Published var enableDeleteAccount: Bool = false
                
    func apply(taps: AuthButtonTaps) {
        isLoading = true
        successStatus = .none
        alertType = .none
        // 非同期処理中は、SignUp/SignIn/DeleteAcountボタン非活性
        enableSignUp = false
        enableSignIn = false
        enableDeleteAccount = false
        
        switch taps {
        case .trialUse:
            self.getTrialUserInfo()
        case .signUp:
            self.signUp()
        case .signIn:
            self.signIn()
        case .deleteAccount:
            self.deleteAccount(email: email, password: password)
        }
    }
    
    // MARK: - private
    private let keyChainManager: KeyChainManager = KeyChainManager()
    private let myAppErrorSubject = PassthroughSubject<MyAppError, Never>()
    private var cancellableBag = Set<AnyCancellable>()
    
    // MARK: - Dependencies
    private let apiService: APIServiceType
    
    // MARK: - AnyPublisher
    private var usernameValidPublisher: AnyPublisher<AuthInputValidation, Never> {
        return $userName
            .map {
                let error = AuthInputValidation.self
                return $0.isEmpty ? error.missingUsername : error.noError
            }
            .eraseToAnyPublisher()
    }
    
    private var emailValidPublisher: AnyPublisher<(email: String, error: AuthInputValidation), Never> {
        return $email
        // SignIn/SignUpセグメントの切り替え時、$segmentTyepを発火
            .combineLatest($authSegmentType)
            .map { email, segmentType in
                let error = AuthInputValidation.self
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
    
    private var emailServerValidPublisher: AnyPublisher<AuthInputValidation, Never> {
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
                let error = AuthInputValidation.self
                return !$0 ? error.noError : error.emailAlreadyUsed
            }
            .eraseToAnyPublisher()
    }
    
    private var passwordValidPublisher: AnyPublisher<AuthInputValidation, Never> {
        return $password
            .map {
                let error = AuthInputValidation.self
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
    
    private var segmentOnChangedPublisher: AnyPublisher<AuthSegmentType, Never> {
        return $authSegmentType
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
        
        self.showTermsAndConditions = email.isEmpty && password.isEmpty
        
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
                return (error == .emailAlreadyUsed && self.authSegmentType == .signInSegment) ? "" : error.errorDescription
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
            Publishers.CombineLatest4(
                usernameValidPublisher,
                emailValidPublisher,
                emailServerValidPublisher,
                passwordValidPublisher),
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
                let enableButton = [emailValidation.error, passwordValidation].allSatisfy { $0 == .noError }
                self.enableSignIn = enableButton
                self.enableDeleteAccount = enableButton
            }
        }
        .store(in: &cancellableBag)
        
        myAppErrorSubject
            .sink(receiveValue: { [weak self] (error) in
                guard let self = self else { return }
                self.isLoading = false
                self.successStatus = .none
                self.myAppErrorMsg = error.localizedDescription
                self.alertType = .error
                
                self.enableSignUp = true
                self.enableSignIn = true
                self.enableDeleteAccount = true
                
                // 再度値を流し、認証ボタンの非/活性を判定
                self.email = email
                self.password = password
            })
            .store(in: &cancellableBag)
    }
    
    deinit {
        cancellableBag.removeAll()
    }
}

// MARK: - HTTPリクエスト＆レスポンスハンドリング
extension AuthViewModel {
    
    // リクエスト
    private func handleRequest<T, R>(request: R) -> AnyPublisher<T, Never> where R: CommonHttpRouter, T: Decodable {
        apiService.request(with: request)
            .receive(on: RunLoop.main)
            .catch { [weak self] error -> Empty<Decodable, Never> in
                guard let self = self else { return .init() }
                self.myAppErrorSubject.send(error)
                return .init()
            }
            .flatMap { value -> AnyPublisher<T, Never> in
                guard let castedValue = value as? T else { return Empty().eraseToAnyPublisher() }
                return Just(castedValue).eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    // お試し利用用のユーザー情報を取得
    private func getTrialUserInfo() {
        let getTrialUserInfoRequest = GetTrialUserInfoRequest()
        // リクエスト組み立て
        handleRequest(request: getTrialUserInfoRequest)
            .sink(receiveValue: { [weak self] (trialAuthModel: AuthModel) in
                guard let self = self else { return }
                // お試し利用用のユーザ情報でサインイン
                self.signIn(trialUserInfo: trialAuthModel)
            })
            .store(in: &cancellableBag)
    }
    
    // サインアップ/サインイン
    private func authenticate(with request: any CommonHttpRouter, authModel: AuthModel) {
        // リクエスト
        handleRequest(request: request)
            .sink(receiveValue: { [weak self] (value: AuthModel) in
                guard let self = self else { return }
                self.isLoading = false
                self.successStatus = .signedUpIn
                self.enableSignUp = true
                self.enableSignIn = true
                self.enableDeleteAccount = true
                // 認証情報をキーチェーンへ保存
                self.keyChainManager.saveCredentials(
                    apiToken: value.apiToken,
                    username: value.name,
                    email: value.email,
                    password: value.password
                )
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
    private func signIn(trialUserInfo trialAuthModel: AuthModel? = nil) {
        let authModel = AuthModel(
            name: "",
            email: email,
            password: password,
            apiToken: "",
            isDuplicatedEmail: nil
        )
        // サインインリクエスト組み立て
        let signInRequest = SignInRequest(model: trialAuthModel ?? authModel)
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
    
    // アカウント削除
    private func deleteAccount(email: String, password: String) {
        let authModel = AuthModel(
            name: "",
            email: email,
            password: password,
            apiToken: "",
            isDuplicatedEmail: nil
        )
        // リクエスト組み立て
        let deleteAccountRequest = DeleteAccountRequest(model: authModel)
        // リクエスト
        handleRequest(request: deleteAccountRequest)
            .sink(receiveValue: { [weak self] (value: EmptyModel) in
                guard let self = self else { return }
                self.isLoading = false
                self.successStatus = .accountDeleted
                self.alertType = .none
                self.enableDeleteAccount = true
                // 認証情報をキーチェーンから削除
                self.keyChainManager.deleteCredentials()
                
                // 値をリセット
                self.email = ""
                self.password = ""
            })
            .store(in: &cancellableBag)
    }
}
