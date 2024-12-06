//
//  AppSupportView.swift
//  SwiftUIApp
//
//  Created by 鈴木 健太 on 2024/12/06.
//

import Foundation
import SwiftUI
import SwiftUI

struct AppSupportView: View {
    
    @Binding var isPresented: Bool
    
    // ボタンスタイルを共通化
    private struct ActionButton: View {
        let title: String
        var color: Color = ColorCodes.primary.color()
        var font: UIFont.Weight = .bold
        let action: () -> Void
        
        var body: some View {
            Button(action: action) {
                Text(title)
                    .fontWeight(.bold)
                    .foregroundStyle(color)
            }
        }
    }
    
    // リンクを開く
    private func openUrl(url: URL?) {
        if let url = url {
            UIApplication.shared.open(url) {
                print(!$0 ? "Could not access URL" : "")
            }
        } else {
            print("Invalid URL")
        }
    }
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            
            VStack(spacing: 26) {
                // お問い合わせボタン
                ActionButton(title: "お問い合わせ") {
                    openUrl(url: MyAppSettings.contactFormUrl)
                }
                
                // プライバシーポリシーボタン
                ActionButton(title: "プライバシーポリシー") {
                    openUrl(url: MyAppSettings.privacyPolicyUrl)
                }
                
                // 利用規約ボタン
                ActionButton(title: "利用規約") {
                    openUrl(url: MyAppSettings.termsAndConditionsUrl)
                }
                
                // 閉じるボタン
                ActionButton(title: "閉じる", color: .red, font: .regular) {
                    isPresented.toggle()
                }
                .padding(.top, 20) // 閉じるボタンの上に余白を追加
            }
            .padding(32)
            .background(Color.white)
            .cornerRadius(35)
        }
    }
}
