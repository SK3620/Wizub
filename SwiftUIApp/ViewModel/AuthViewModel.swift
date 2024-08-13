//
//  AuthViewModel.swift
//  SwiftUIApp
//
//  Created by 鈴木 健太 on 2024/08/11.
//

import Foundation
import Combine

class AuthViewModel: ObservableObject {
    
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
    
    init() {
        
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
        
        Publishers.CombineLatest3(usernameValidPublisher, emailValidPublisher, passwordValidPublisher)
            .receive(on: RunLoop.main)
            .map { userName, email, password in
                return [userName, email, password].allSatisfy { $0 == .noError }
            }
            .assign(to: \.enableSignUp, on: self)
            .store(in: &cancellableBag)
    }
    
    deinit {
        cancellableBag.removeAll()
    }
}
