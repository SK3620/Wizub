//
//  TranslateView.swift
//  SwiftUIApp
//
//  Created by 鈴木 健太 on 2024/08/29.
//

import SwiftUI

struct TranslateView: View {
    
    @State var segmentType: TranslateSegmentType = .selected
    
    // 選択した字幕
    var pendingTranslatedSubtitles: [SubtitleModel.SubtitleDetailModel]
    // 全ての字幕
    var allSubtitles: [SubtitleModel.SubtitleDetailModel]
    // 選択した字幕の翻訳
    var translateSelected: () -> Void
    // 全ての字幕の翻訳
    var translateAll: () -> Void
    
    init(
         pendingTranslatedSubtitles: [SubtitleModel.SubtitleDetailModel],
         allSubtitles: [SubtitleModel.SubtitleDetailModel],
         translateSelected: @escaping () -> Void,
         translateAll: @escaping () -> Void)
    {
        self.pendingTranslatedSubtitles = pendingTranslatedSubtitles
        self.allSubtitles = allSubtitles
        self.translateSelected = translateSelected
        self.translateAll = translateAll
    }
    
    var body: some View {
        VStack(spacing: 16) {
            
            Text("翻訳リスト")
                .font(.title2)
                .fontWeight(.medium)
            
            // 選択中の字幕リスト/全ての字幕リスト表示切り替え
            TranslateSegmentedControl(selectedSegment: $segmentType)
            
            // 字幕をリスト表示
            SubtitleList(subtitles: segmentType == .selected ? pendingTranslatedSubtitles : allSubtitles)
            
            // 翻訳ボタン
            TranslateButton(
                action: segmentType == .selected ? translateSelected : translateAll,
                title: "ChatGPT 翻訳"
            )
        }
        .padding()
    }
}

// 字幕リスト
struct SubtitleList: View {
    var subtitles: [SubtitleModel.SubtitleDetailModel]
    
    var body: some View {
        List(subtitles) {
            Text($0.enSubtitle)
        }
        .listStyle(.inset)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .background(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray, lineWidth: 0)
        )
    }
}

// 翻訳ボタン
struct TranslateButton: View {
    var action: () -> Void
    var title: String
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Text(title)
                    .font(.headline)
            }
            .foregroundColor(.white)
            .padding(.horizontal, 40)
            .padding(.vertical, 16)
            .background(
                Capsule()
                    .fill(ColorCodes.primary.color())
            )
        }
    }
}
