//
//  AuthView.swift
//  SwiftUIApp
//
//  Created by 鈴木 健太 on 2024/08/11.
//

import SwiftUI

struct AuthView: View {
    
    @ObservedObject var authViewModel: AuthViewModel
    
    var body: some View {
        VStack {
            VStack {
                if authViewModel.segmentType == .signUpSegment {
                    // ユーザー名入力欄
                    AuthTextField(title: "UserName", textValue: $authViewModel.userName, errorValue: authViewModel.userNameError)
                        .onChange(of: authViewModel.userName) { oldValue, newValue in
                            // 17文字以上＆スペースは切り捨て
                            authViewModel.userName = newValue.limited()
                        }
                }
                
                // Eメール入力欄
                AuthTextField(title: "Email", textValue: $authViewModel.email, errorValue: authViewModel.emailError, keyboardType: .emailAddress)
                
                // パスワード入力欄
                AuthTextField(title: "Password", textValue: $authViewModel.password, errorValue: authViewModel.passwordError, isSecured: true)
                    .onChange(of: authViewModel.password) { oldValue, newValue in
                        // 17文字以上＆スペースは切り捨て
                        authViewModel.password = newValue.limited()
                    }
                
                // サインイン/サインアップボタン
                AuthButton(authViewModel: authViewModel)
                    .padding(.vertical, 40)
            }
            .padding(.horizontal)
            .padding(.top, 50)
        }
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 35))
        .shadow(color: .gray.opacity(0.7), radius: 5)
        .padding(.horizontal)
    }
}
