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
                    Text("選択中の字幕がありません")
                        .font(.headline)
                        .foregroundColor(ColorCodes.primaryGray.color())
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
}
