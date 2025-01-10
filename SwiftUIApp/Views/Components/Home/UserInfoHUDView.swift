//
//  UserInfoHUDView.swift
//  SwiftUIApp
//
//  Created by 鈴木 健太 on 2025/01/09.
//

import Foundation
import SwiftUI

struct UserInfoHUDView: View {
    private let keyChainManager = KeyChainManager()
    private var username: String {
        return keyChainManager.loadCredentials(service: .usernameService)
    }
    private var email: String {
        return keyChainManager.loadCredentials(service: .emailService)
    }
    
    var body: some View {
        VStack {
            VStack(spacing: 8) {
                Text("現在ログイン中")
                    .font(.headline)
                    .foregroundColor(.black)
                    .padding(.bottom, 8)
                Text(keyChainManager.loadCredentials(service: .usernameService))
                    .font(.title)
                    .foregroundColor(.black)
                if !email.isEmpty {
                    Text(email)
                        .font(.title2)
                        .foregroundColor(.black)
                }
            }
            .padding(.horizontal, 32)
            .padding(.vertical, 16)
            .background(ColorCodes.primary2.color())
            .cornerRadius(15)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.2))
    }
}

