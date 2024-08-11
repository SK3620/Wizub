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
    
    // 初期値はログイン画面
    @Published var segmentType: SegmentType = .loginSegment
    
    @Published var userName: String = ""
    @Published var usernameError: String = ""
    
    @Published var email: String = ""
    @Published var emailError: String = ""
    
    @Published var password: String = ""
    @Published var passwordError: String = ""
    
    @Published var confirmPassword: String = ""
    @Published var confirmPasswordError: String = ""
    
    private var userNameValidPublisher: AnyPublisher<Bool, Never> {
        return $userName
            .map {
                !$0.isEmpty
            }
            .eraseToAnyPublisher()
    }
    
    init(){
        userNameValidPublisher
            .receive(on: RunLoop.main)
            .dropFirst()
            .map { $0 ? "" : "Username is missing"}
            .assign(to: \.usernameError, on: self)
            .store(in: &cancellableBag)
    }
}
