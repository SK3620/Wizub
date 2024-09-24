//
//  TranslateButton.swift
//  SwiftUIApp
//
//  Created by 鈴木 健太 on 2024/09/24.
//

import SwiftUI

// 翻訳ボタン
struct TranslateButton: View {
    var action: () -> Void
    var title: String
    var disableButton: Bool
    
    var body: some View {
        VStack(spacing: 4) {
            Button {
                action()
            } label: {
                HStack(spacing: 16) {
                    Text(title)
                        .font(.headline)
                }
                .foregroundColor(.white)
                .padding(.horizontal, 40)
                .padding(.vertical, 16)
                .background(
                    Capsule()
                        .fill(!disableButton ? ColorCodes.buttonBackground.color() : ColorCodes.buttonBackground.color().opacity(0.3))
                )
            }
            .disabled(disableButton)
        }
    }
}
