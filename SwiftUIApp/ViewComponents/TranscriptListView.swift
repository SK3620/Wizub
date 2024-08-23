//
//  TranscriptListView.swift
//  SwiftUIApp
//
//  Created by 鈴木 健太 on 2024/08/22.
//

import SwiftUI

struct TranscriptListView: View {
    
    private var transcriptDetailModel: TranscriptModel.TranscriptDetailModel
    var isHighlighted: Bool // 現在の字幕がハイライトされているかどうか

    
    init(transcriptDetailModel: TranscriptModel.TranscriptDetailModel, isHighlighted: Bool){
        self.transcriptDetailModel = transcriptDetailModel
        self.isHighlighted = isHighlighted
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(transcriptDetailModel.text)
                .font(.body)
                .foregroundColor(isHighlighted ? .red : .primary) // ハイライトされた字幕は赤色
            HStack {
                Text("開始時間: \(transcriptDetailModel.start)秒")
                Text("持続時間: \(transcriptDetailModel.duration)秒")
            }
            .font(.caption)
            .foregroundColor(.gray)
        }
        .padding(.vertical, 4)
        .id(transcriptDetailModel.id)
    }
}

