//
//  AuthButton.swift
//  SwiftUIApp
//
//  Created by 鈴木 健太 on 2024/09/05.
//

import SwiftUI

struct AuthButton: View {
    
    @ObservedObject var authViewModel: AuthViewModel
    var segmentType: AuthSegmentType
    var title: String
    var enableButton: Bool
    
    init(authViewModel: AuthViewModel) {
        self.authViewModel = authViewModel
        self.segmentType = authViewModel.authSegmentType
        self.title = segmentType.title
        self.enableButton = segmentType == .signUpSegment ? authViewModel.enableSignUp : authViewModel.enableSignIn
    }
    
    var body: some View {
        
        Button(action: {
            if segmentType == .signUpSegment {
                // サインアップ
                authViewModel.apply(taps: .signUp)
            } else {
                // サインイン
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
