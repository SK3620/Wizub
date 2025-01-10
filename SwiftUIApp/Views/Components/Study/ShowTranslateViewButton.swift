//
//  showTranslateViewButton.swift
//  SwiftUIApp
//
//  Created by 鈴木 健太 on 2024/09/09.
//

import SwiftUI

struct ShowTranslateViewButton: View {
    
    var isShowTranslateView: () -> Void
    
    init(isShowTranslateView: @escaping () -> Void) {
        self.isShowTranslateView = isShowTranslateView
    }
    
    var body: some View {
        Button(action: {
            isShowTranslateView()
        }) {
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    HStack(spacing: 4) {
                        Image(systemName: "translate")
                            .font(.system(size: 15))
                            .foregroundColor(.white)
                            .padding(6)
                            .background(
                                Circle()
                                    .fill(.clear)
                                    .overlay(Circle().stroke(.white, lineWidth: 1))
                            )
                        
                        Text("AI 翻訳")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(ColorCodes.primary.color())
                            .shadow(color: .gray.opacity(0.7), radius: 5, x: 0, y: 5)
                    )
                }
            }
        }
    }
}
