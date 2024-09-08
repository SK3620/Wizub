//
//  TranscriptListView.swift
//  SwiftUIApp
//
//  Created by 鈴木 健太 on 2024/08/22.
//

import SwiftUI

struct SubtitleListView: View {
    
    private var subtitleDetails: SubtitleModel.SubtitleDetailModel
    
    // 現在の字幕がハイライトされているかどうか
    private var isHighlighted: Bool
    
    // 字幕表示モード
    private var displayMode: SubtitleDisplayMode
    
    // 編集
    private var editSubtitle: (Bool) -> Void
    
    // 翻訳する字幕を配列に格納する
    private var storeSubtitles: () -> Void
    
    // 格納した字幕を配列から除外する
    private var removeSubtitle: () -> Void
    
    // 翻訳アイコン切り替え
    @State private var toggleTranslateIcon: Bool = false
    
    // 編集/翻訳アイコンを表示するかどうか
    private var showTranslateEditIcon: Bool = false
    
    init(subtitleDetails: SubtitleModel.SubtitleDetailModel, isHighlighted: Bool, displayMode: SubtitleDisplayMode, showTranslateEditIcon: Bool, storeSubtitles: @escaping () -> Void, removeSubtitle: @escaping () -> Void, editSubtitle: @escaping (Bool) -> Void) {
        self.subtitleDetails = subtitleDetails
        self.isHighlighted = isHighlighted
        self.displayMode = displayMode
        self.showTranslateEditIcon = showTranslateEditIcon
        self.storeSubtitles = storeSubtitles
        self.removeSubtitle = removeSubtitle
        self.editSubtitle = editSubtitle
    }
    
    var body: some View {
        HStack {
            HStack {
                VStack(alignment: .leading) {
                    if displayMode != .hideEnglish && displayMode != .hideAll {
                        Text(subtitleDetails.enSubtitle)
                            .font(.body)
                            .foregroundColor(isHighlighted ? .red : .primary)
                    }
                    
                    if displayMode != .hideJapanese && displayMode != .hideAll {
                        HStack {
                            // 日本語訳を取り出す
                            Text(subtitleDetails.jaSubtitle)
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
                            editSubtitle(true)
                        } label: {
                            Image(systemName: "pencil")
                                .font(.system(size: 20))
                        }
                        .buttonStyle(BorderlessButtonStyle())
                        
                        Button {
                            // 配列から除外 or 配列に格納
                            toggleTranslateIcon ? removeSubtitle() : storeSubtitles()
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
        .id(subtitleDetails.id)
    }
}
