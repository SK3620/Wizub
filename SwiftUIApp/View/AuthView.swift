//
//  AuthView.swift
//  SwiftUIApp
//
//  Created by 鈴木 健太 on 2024/08/11.
//

import SwiftUI

struct AuthView: View {
    
    @ObservedObject var authViewModel: AuthViewModel
    var segmentType: SegmentType
    
    var body: some View {
        VStack {
            VStack {
                if segmentType == .signUpSegment {
                    AuthTextField(title: "UserName", textValue: $authViewModel.userName, errorValue: authViewModel.userNameError)
                        .onChange(of: authViewModel.userName) { oldValue, newValue in
                            // 17文字以上＆スペースは切り捨て
                            authViewModel.userName = newValue.limited()
                        }
                }
                
                AuthTextField(title: "Email", textValue: $authViewModel.email, errorValue: authViewModel.emailError, keyboardType: .emailAddress)
                
                AuthTextField(title: "Password", textValue: $authViewModel.password, errorValue: authViewModel.passwordError, isSecured: true)
                    .onChange(of: authViewModel.password) { oldValue, newValue in
                        // 17文字以上＆スペースは切り捨て
                        authViewModel.password = newValue.limited()
                    }
                
                AuthButton(authViewModel: authViewModel, segmentType: segmentType)
                    .padding(.top, 40)
                    .padding(.bottom, segmentType == .signInSegment ? 0 : 40)
                
                if segmentType == .signInSegment {
                    Button {
                        authViewModel.apply(taps: .forgetPassword)
                    } label: {
                        Text("Forget your password?")
                            .font(.title3)
                    }
                    .padding(.vertical, 24)
                }
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

struct AuthTextField: View {
    
    var title: String
    @Binding var textValue: String
    var errorValue: String
    var isSecured: Bool = false
    var keyboardType: UIKeyboardType = .default
    
    @State private var isEditing: Bool = false
    
    var body: some View {
        VStack {
            ZStack(alignment: .leading) {
                Text(title)
                    .font(.title2)
                    .foregroundColor(.gray)
                    .background(Color.white)
                    .padding(.horizontal, 0)
                    .scaleEffect(isEditing || !textValue.isEmpty ? 0.8 : 1.0, anchor: .leading)
                    .offset(y: isEditing || !textValue.isEmpty ? -35 : 0)
                    .animation(.easeInOut(duration: 0.2), value: isEditing || !textValue.isEmpty)
                
                VStack {
                    if isSecured {
                        SecureField("", text: $textValue, onCommit: {
                            // エンター押下時
                            self.isEditing = false
                        })
                            .font(.title2)
                            .padding()
                            .keyboardType(keyboardType)
                            .onTapGesture {
                                // フィールド押下時
                                self.isEditing = true
                            }
                    } else {
                        TextField("", text: $textValue, onEditingChanged: { editing in
                            self.isEditing = editing
                        })
                        .font(.title2)
                        .padding()
                        .keyboardType(keyboardType)
                    }
                    Divider()
                        .padding(.top, -17)
                }
            }
            
            Text(errorValue)
                .fontWeight(.light)
                .foregroundStyle(ColorCodes.failure.color())
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .trailing)
                .padding(EdgeInsets(top: -24, leading: 0, bottom: 24, trailing: 0))
        }
    }
}

struct AuthButton: View {
    
    @ObservedObject var authViewModel: AuthViewModel
    var segmentType: SegmentType
    var title: String
    var enableButton: Bool
    
    init(authViewModel: AuthViewModel, segmentType: SegmentType) {
        self.authViewModel = authViewModel
        self.segmentType = segmentType
        self.title = segmentType == .signUpSegment ? "Sign Up" : "Sign In"
        self.enableButton = segmentType == .signUpSegment ? authViewModel.enableSignUp : authViewModel.enableSignIn
    }
    
    var body: some View {
        
        Button(action: {
            // ローディングアイコン表示開始
            authViewModel.statusViewModel = StatusViewModel(isLoading: true)
            if segmentType == .signUpSegment {
                authViewModel.apply(taps: .signUp)
            } else {
                authViewModel.apply(taps: .signIn)
            }
        }, label: {
            Text(title)
                .padding(.vertical)
                .padding(.horizontal, 60)
                .font(.title2)
                .foregroundColor(.white)
                .background(enableButton ? ColorCodes.buttonBackground.color() : ColorCodes.buttonBackground.color().opacity(0.3) )
                .clipShape(RoundedRectangle(cornerRadius: 35))
        })
        .disabled(!enableButton)
    }
}
