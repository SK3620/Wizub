//
//  AuthView.swift
//  SwiftUIApp
//
//  Created by 鈴木 健太 on 2024/08/11.
//

import SwiftUI

struct AuthView: View {
    
    @ObservedObject var authViewModel: AuthViewModel
    
    // 親ビューで管理されるフォーカス状態をバインド 現在のフォーカス状態の読み書き可能
    @FocusState.Binding var focusedState: Bool
 
    private var segmentType: AuthSegmentType {
        return authViewModel.authSegmentType
    }
    
    var body: some View {
        VStack {
            VStack {
                if segmentType == .signUpSegment {
                    // ユーザー名入力欄
                    AuthTextField(title: "UserName", textValue: $authViewModel.userName, errorValue: authViewModel.userNameError)
                        .focused($focusedState)
                        .onChange(of: authViewModel.userName) { oldValue, newValue in
                            // 17文字以上＆スペースは切り捨て
                            authViewModel.userName = newValue.limited()
                        }
                }
                
                // Eメール入力欄
                AuthTextField(title: "Email", textValue: $authViewModel.email, errorValue: authViewModel.emailError, keyboardType: .emailAddress)
                    .focused($focusedState)
                
                // パスワード入力欄
                AuthTextField(title: "Password", textValue: $authViewModel.password, errorValue: authViewModel.passwordError, isSecured: true)
                    .focused($focusedState)
                    .onChange(of: authViewModel.password) { oldValue, newValue in
                        // 17文字以上＆スペースは切り捨て
                        authViewModel.password = newValue.limited()
                    }
                
                // サインイン/サインアップボタン
                AuthButton(authViewModel: authViewModel)
                    .padding(.vertical, 40)
                
                if segmentType == .signInSegment {
                    DeleteAccountButton(authViewModel: authViewModel)
                        .padding(.bottom, 40)
                }
            }
            .padding(.horizontal)
            .padding(.top, 50)
        }
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 35))
//        .shadow(color: .gray.opacity(0.7), radius: 5)
        .padding(.horizontal)
    }
}
