//
//  CustomProgressView.swift
//  SwiftUIApp
//
//  Created by 鈴木 健太 on 2024/08/26.
//

import SwiftUI

struct CommonProgressView: View {
    
    var text: String = ""
    
    var body: some View {
        VStack {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .purple))
                .scaleEffect(2.5)
                .padding()
            
            if !text.isEmpty {
                Text(text)
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .foregroundColor(ColorCodes.primary.color())
            }
        }
        .padding()
        // テキストが空の場合はローディングアイコンのみ表示
        .background(text.isEmpty ? .clear : ColorCodes.primary2.color())
        .cornerRadius(15)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(text.isEmpty ? .clear : ColorCodes.primary.color().opacity(0.5), lineWidth: 1) // 枠線の色と太さを指定
        )
    }
}

#Preview {
    CommonProgressView()
}
