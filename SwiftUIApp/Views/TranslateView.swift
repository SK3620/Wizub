//
//  TranslateView.swift
//  SwiftUIApp
//
//  Created by 鈴木 健太 on 2024/08/29.
//

import SwiftUI

enum TranslateSegmentType: CommonSegmentTypeProtocol {
    
    // 選択された字幕の翻訳を行うセグメント
    case selected
    // 全ての字幕の翻訳を行うセグメント
    case all
    
    // 自身のインスタンスを識別子とする
    var id: Self {
        return self
    }

    var title: String {
        switch self {
        case .selected:
            return "選択中"
        case .all:
            return "全て"
        }
    }
    
    var tintColor: Color {
        return ColorCodes.buttonBackground.color()
    }
}

struct TranslateView: View {
    
    @State var segmentType: TranslateSegmentType = .selected
    // 選択された数字
    @State var selectedSectionNum: Int = 0
    
    // 選択した字幕
    var selectedChunkedSubtitles: [[SubtitleModel.SubtitleDetailModel]]
    // 全ての字幕
    var allChunkedSubtitles: [[SubtitleModel.SubtitleDetailModel]]
    // 翻訳
    var translateSubtitles: ([SubtitleModel.SubtitleDetailModel]) -> Void
    
    private var chunkedSubtitles: [[SubtitleModel.SubtitleDetailModel]] {
        switch segmentType {
        case .selected:
            return selectedChunkedSubtitles
        case .all:
            return allChunkedSubtitles
        }
    }
    
    init(
         selectedChunkedSubtitles: [[SubtitleModel.SubtitleDetailModel]],
         allChunkedSubtitles: [[SubtitleModel.SubtitleDetailModel]],
         translateSubtitles: @escaping ([SubtitleModel.SubtitleDetailModel]) -> Void
    ) {
        self.selectedChunkedSubtitles = selectedChunkedSubtitles
        self.allChunkedSubtitles = allChunkedSubtitles
        self.translateSubtitles = translateSubtitles
    }
    
    var body: some View {
        VStack(spacing: 16) {
            
            Text("AI 翻訳")
                .font(.title2)
                .fontWeight(.medium)
            
            // 選択中の字幕リスト/全ての字幕リスト表示切り替え
            CommonSegmentedControl(selectedSegment: $segmentType)
                .shadow(color: .gray, radius: 1)
            
            // 字幕要素数が2以上ならば、セクションを表示する
            if chunkedSubtitles.count > 1 {
                // 翻訳する字幕数を分割するセクション
                ChunkedSubtitleSegmentControl(sectionNumCount: chunkedSubtitles.count, selectedSectionNum: $selectedSectionNum)
                    .padding(.top, -8) // 上のUIパーツとの間隔を狭める
            }
            
            // 字幕をリスト表示
            SubtitleList(subtitles: chunkedSubtitles.isEmpty ? [] : chunkedSubtitles[selectedSectionNum] )
            
            // 翻訳ボタン
            TranslateButton(
                action: { translateSubtitles(chunkedSubtitles[selectedSectionNum])},
                title: "翻訳する",
                disableButton: chunkedSubtitles.isEmpty
            )
        }
        .padding()
    }
}
