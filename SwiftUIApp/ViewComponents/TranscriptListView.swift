//
//  TranscriptListView.swift
//  SwiftUIApp
//
//  Created by 鈴木 健太 on 2024/08/22.
//

import SwiftUI

struct TranscriptListView: View {
    
    private var transcriptDetailModel: TranscriptModel.TranscriptDetailModel
    
    // 現在の字幕がハイライトされているかどうか
    var isHighlighted: Bool
    
    // 字幕表示モード
    var displayMode: TranscriptDisplayMode
    
    init(transcriptDetailModel: TranscriptModel.TranscriptDetailModel, isHighlighted: Bool, displayMode: TranscriptDisplayMode){
        self.transcriptDetailModel = transcriptDetailModel
        self.isHighlighted = isHighlighted
        self.displayMode = displayMode
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            if displayMode != .hideEnglish && displayMode != .hideAll {
                Text(transcriptDetailModel.text)
                    .font(.body)
                    .foregroundColor(isHighlighted ? .red : .primary)
            }
            
            if displayMode != .hideJapanese && displayMode != .hideAll {
                HStack {
                    Text("開始時間: \(transcriptDetailModel.start)秒")
                    Text("持続時間: \(transcriptDetailModel.duration)秒")
                }
                .font(.caption)
                .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 4)
        .id(transcriptDetailModel.id)
    }
}

