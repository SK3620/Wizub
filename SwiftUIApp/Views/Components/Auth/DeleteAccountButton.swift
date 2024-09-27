//
//  DeleteAccountButton.swift
//  SwiftUIApp
//
//  Created by 鈴木 健太 on 2024/09/27.
//

import SwiftUI

struct DeleteAccountButton: View {
        
    @ObservedObject var authViewModel: AuthViewModel
        
    init(authViewModel: AuthViewModel) {
        self.authViewModel = authViewModel
    }
    
    var body: some View {
        HStack {
            Spacer()
            Button(action: {
                authViewModel.alertType = .deleteAccount
            }, label: {
                Text("アカウントを削除する")
                    .fontWeight(.medium)
                    .foregroundColor(authViewModel.enableDeleteAccount ? .red : Color(UIColor.lightGray))
                    .underline(color: authViewModel.enableDeleteAccount ? .red : Color(UIColor.lightGray))
                    .baselineOffset(2.0)
            })
            .disabled(!authViewModel.enableDeleteAccount)
            Spacer()
        }
    }
}
