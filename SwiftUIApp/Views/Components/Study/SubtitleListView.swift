//
//  TranscriptListView.swift
//  SwiftUIApp
//
//  Created by 鈴木 健太 on 2024/08/22.
//

import SwiftUI

struct SubtitleListView: View {
    
    private var subtitleDetail: SubtitleModel.SubtitleDetailModel
    
    // 現在の字幕がハイライトされているかどうか
    private var isHighlighted: Bool
    
    // 編集/翻訳アイコンを表示するかどうか
    private var isShowTranslateEditIcon: Bool = false
    
    // 翻訳アイコンが押下されているかどうか
    private var isSubtitleSelected: Bool = false
    
    // 編集
    private var editSubtitle: () -> Void
    
    // 翻訳する字幕を配列に格納する
    private var storeSubtitles: () -> Void
    
    // 格納した字幕を配列から除外する
    private var removeSubtitle: () -> Void
    
    init(
        subtitleDetail: SubtitleModel.SubtitleDetailModel,
        isHighlighted: Bool,
        isShowTranslateEditIcon: Bool,
        isSubtitleSelected: Bool,
        storeSubtitles: @escaping () -> Void,
        removeSubtitle: @escaping () -> Void,
        editSubtitle: @escaping () -> Void
    ) {
        self.subtitleDetail = subtitleDetail
        self.isHighlighted = isHighlighted
        self.isShowTranslateEditIcon = isShowTranslateEditIcon
        self.isSubtitleSelected = isSubtitleSelected
        self.storeSubtitles = storeSubtitles
        self.removeSubtitle = removeSubtitle
        self.editSubtitle = editSubtitle
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                // 英語字幕
                Text(subtitleDetail.enSubtitle)
                    .font(.body)
                // ハイライトされる字幕の色
                    .foregroundColor(isHighlighted ? ColorCodes.primaryBlack.color() : ColorCodes.primaryGray2.color())
                
                if !subtitleDetail.jaSubtitle.isEmpty {
                    // 日本語字幕
                    Text(subtitleDetail.jaSubtitle)
                        .font(.body)
                    // ハイライトされる字幕の色
                        .foregroundColor(isHighlighted ? ColorCodes.primaryBlack.color() : ColorCodes.primaryGray2.color())
                }
            }
            .padding([.vertical, .horizontal], 16)
            
            Spacer()
                        
            // 編集/翻訳アイコンを非/表示
            if isShowTranslateEditIcon {
                translationEditIcons
            }
        }
        .listRowBackground(isHighlighted ? ColorCodes.primary2.color() : Color.white) // ハイライトされる字幕の背景色
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
        .id(subtitleDetail.id)
    }
    
    private var translationEditIcons: some View {
        VStack(spacing: 16) {
            
            // 編集ボタン
            Button {
                editSubtitle()
            } label: {
                Image(systemName: "pencil")
                    .font(.system(size: 20))
            }
            .buttonStyle(PlainButtonStyle()) // ボタン枠内をタップ領域にする
            
            // 翻訳ボタン
            Button {
                isSubtitleSelected ? removeSubtitle() : storeSubtitles()
            } label: {
                if isSubtitleSelected {
                    Image(systemName: "translate")
                        .font(.system(size: 15))
                        .foregroundColor(.white)
                        .padding(6)
                        .background(
                            Circle()
                                .fill(ColorCodes.primary.color().opacity(0.7))
                                .overlay(Circle().stroke(ColorCodes.primary.color(), lineWidth: 2))
                        )
                } else {
                    Image(systemName: "translate")
                        .font(.system(size: 15))
                        .foregroundColor(.black)
                        .padding(6)
                        .background(Circle().stroke(Color.gray, lineWidth: 1))
                }
            }
            .buttonStyle(PlainButtonStyle()) // ボタン枠内をタップ領域にする
        }
        .padding(.vertical, 16)
        .padding(.trailing, 12)
    }
}
