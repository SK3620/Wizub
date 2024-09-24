//
//  ChunkedSubtitleSegmentControl.swift
//  SwiftUIApp
//
//  Created by 鈴木 健太 on 2024/09/24.
//

import SwiftUI

// 翻訳する字幕数を分割するセクション
struct ChunkedSubtitleSegmentControl: View {
    // 分割された字幕要素数の数
    var sectionNumCount: Int
    // 選択された数字
    @Binding var selectedSectionNum: Int
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(0..<sectionNumCount, id: \.self) { number in
                    Button(action: {
                        selectedSectionNum = number
                    }) {
                        Text("\(number + 1)")
                            .font(.title3)
                            .fontWeight(.medium)
                            .frame(width: 40, height: 25)
                            .background(selectedSectionNum == number ? ColorCodes.primary.color() : ColorCodes.primaryLightGray.color())
                            .foregroundColor(selectedSectionNum == number ? Color.white : .black)
                            .cornerRadius(25)
                    }
                    .buttonStyle(PlainButtonStyle()) // ボタン枠内をタップ領域にする
                }
            }
            .padding(.horizontal)
        }
        .frame(height: 40)
        .background(.white)
        .cornerRadius(30)
        .shadow(color: .gray, radius: 1)
        .padding(.horizontal, 32)
    }
}
