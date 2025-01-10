//
//  SubtitleList.swift
//  SwiftUIApp
//
//  Created by 鈴木 健太 on 2024/09/24.
//

import SwiftUI

// 字幕リスト
struct SubtitleList: View {
    var subtitles: [SubtitleModel.SubtitleDetailModel]
    
    var body: some View {
        ZStack {
            List(subtitles) {
                Text($0.enSubtitle)
                    .padding([.vertical, .horizontal], 16)
                // 以下は区切り線を端から端まで伸ばす
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .listRowSeparator(.hidden)
                    .listRowInsets(.init(top:0,leading:0,bottom:0,trailing:0))
                    .overlay(
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(.gray.opacity(0.3)),
                        alignment: .bottom
                    )
            }
            .listStyle(.inset)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.gray, lineWidth: 0)
            )
            .shadow(color: .gray, radius: 1)
            
            if subtitles.isEmpty {
                VStack {
                    Spacer()
                    VStack(spacing: 4) {
                        HStack(spacing: 4) {
                            Image(systemName: "translate")
                                .font(.system(size: 15))
                                .foregroundColor(.black)
                                .padding(6)
                                .background(Circle().stroke(Color.gray, lineWidth: 1))
                            
                            Text("をタップして")
                                .font(.headline)
                                .foregroundColor(ColorCodes.primaryGray.color())
                        }
                        Text("翻訳したい字幕を選択してください")
                            .font(.headline)
                            .foregroundColor(ColorCodes.primaryGray.color())
                    }
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
}
