//
//  TranscriptListView.swift
//  SwiftUIApp
//
//  Created by 鈴木 健太 on 2024/08/22.
//

import SwiftUI

struct TranscriptListView: View {
    
    private var transcriptDetailModel: TranscriptModel.TranscriptDetailModel
    
    // 翻訳された字幕（日本語）
    // private var translatedSubtitles: [OpenAIResponseModel2]
    
    // 現在の字幕がハイライトされているかどうか
    private var isHighlighted: Bool
    
    // 字幕表示モード
    private var displayMode: TranscriptDisplayMode
    
    // 編集
    private var editTranscript: (Bool) -> Void
    
    // 翻訳する字幕を配列に格納する
    private var storeTranscript: () -> Void
    
    // 格納した字幕を配列から除外する
    private var removeTranscript: () -> Void
    
    // 翻訳アイコン切り替え
    @State private var toggleTranslateIcon: Bool = false
    
    // 編集/翻訳アイコンを表示するかどうか
    private var showTranslateEditIcon: Bool = false
    
    init(transcriptDetailModel: TranscriptModel.TranscriptDetailModel, isHighlighted: Bool, displayMode: TranscriptDisplayMode, showTranslateEditIcon: Bool, storeTranscript: @escaping () -> Void, removeTranscript: @escaping () -> Void, editTranscript: @escaping (Bool) -> Void) {
        self.transcriptDetailModel = transcriptDetailModel
        self.isHighlighted = isHighlighted
        self.displayMode = displayMode
        self.showTranslateEditIcon = showTranslateEditIcon
        self.storeTranscript = storeTranscript
        self.removeTranscript = removeTranscript
        self.editTranscript = editTranscript
    }
    
    var body: some View {
        HStack {
            HStack {
                VStack(alignment: .leading) {
                    if displayMode != .hideEnglish && displayMode != .hideAll {
                        Text(transcriptDetailModel.enSubtitle)
                            .font(.body)
                            .foregroundColor(isHighlighted ? .red : .primary)
                    }
                    
                    if displayMode != .hideJapanese && displayMode != .hideAll {
                        HStack {
                            // 日本語訳を取り出す
                            Text(transcriptDetailModel.jaSubtitle)
                        }
                        .font(.body)
                        .foregroundColor(isHighlighted ? .red : .primary)
                    }
                }
                .padding(.vertical, 4)
                
                Spacer()
                
                // 編集/翻訳アイコンを非/表示
                if showTranslateEditIcon {
                    // ハイライトされている字幕のみ
                    VStack(spacing: 24) {
                        
                        Spacer()
                        
                        // 編集ボタン
                        Button {
                            // 編集画面の表示フラグ
                            editTranscript(true)
                        } label: {
                            Image(systemName: "pencil")
                                .font(.system(size: 20))
                        }
                        .buttonStyle(BorderlessButtonStyle())
                        
                        Button {
                            // 配列から除外 or 配列に格納
                            toggleTranslateIcon ? removeTranscript() : storeTranscript()
                            toggleTranslateIcon.toggle()
                        } label: {
                            ZStack {
                                if toggleTranslateIcon {
                                    Image(systemName: "translate")
                                        .font(.system(size: 18))
                                        .foregroundColor(.white)
                                        .padding(7)
                                        .background(
                                            Circle()
                                                .fill(ColorCodes.primary.color().opacity(0.7))
                                                .overlay(Circle().stroke(ColorCodes.primary.color(), lineWidth: 2))
                                        )
                                } else {
                                    Image(systemName: "translate")
                                        .font(.system(size: 18))
                                        .foregroundColor(.black)
                                        .padding(7)
                                        .background(Circle().stroke(Color.gray, lineWidth: 1))
                                }
                            }
                        }
                        .buttonStyle(BorderlessButtonStyle())
                        
                        Spacer()
                    }
                }
            }
        }
        .id(transcriptDetailModel.id)
    }
}
