//
//  MenuTabBarView.swift
//  SwiftUIApp
//
//  Created by 鈴木 健太 on 2024/08/26.
//

import SwiftUI

struct MenuTabBarView: View {
    
    // 字幕同期するかどうか
    @Binding var isSubtitleSync: Bool
    // 編集/翻訳アイコンを表示するかどうかを処理
    var toggleTranslateEditIcon: () -> Void
    // 再生速度変更
    var changePlaybackRate: () -> Void
    // 再生速度
    var playBackRate: PlayBackRate
    // 翻訳アイコンが全選択/全未選択かどうか
    @Binding var isTranslateIconSelectedAll: Bool
    // 翻訳する字幕を格納する配列を操作
    var appendOrRemoveAllSubtitles: () -> Void
    
    // 翻訳/編集アイコンボタンにスラッシュを入れるかどうか
    @State var isTranslateEditIconSlashed: Bool = true
    
    var body: some View {
        HStack(spacing: 40) {
            // 字幕同期
            VStack(spacing: 0) {
                Button(action: {
                    isSubtitleSync.toggle()
                }) {
                    ZStack {
                        Image(systemName: "doc.text.below.ecg")
                            .font(.system(size: 22, weight: .medium))
                            .foregroundColor(.black)
                        
                        // アイコンにスラッシュを入れる
                        CommonSlashDivider(
                            color: isSubtitleSync ? .black : .clear,
                            width: 55
                        )
                    }
                }
                Text("字幕同期")
                    .font(.caption)
            }
            
            // 再生速度
            VStack {
                Button(action: {
                    changePlaybackRate()
                }) {
                    Text("\(playBackRate.toString())")
                        .font(.system(size: 23, weight: .medium))
                        .foregroundColor(.black)
                }
                Text("再生速度")
                    .font(.caption)
                    .padding(.top, -13)
            }
            .frame(width: 80) // 横幅を設定し、切り替え時、左右のTabItemのUIに影響がないようにする
            .padding(.top, -2)
            
            // 編集＆翻訳アイコンの非/表示切り替え
            VStack {
                Button(action: {
                    isTranslateEditIconSlashed.toggle()
                    toggleTranslateEditIcon()
                }) {
                    ZStack {
                        HStack(spacing: 0) {
                            Image(systemName: "translate")
                                .font(.system(size: 15))
                                .foregroundColor(.black)
                            Text("/")
                                .foregroundColor(.black)
                            Image(systemName: "pencil")
                                .font(.system(size: 15))
                                .foregroundColor(.black)
                        }
                        
                        // アイコンにスラッシュを入れる
                        CommonSlashDivider(
                            color: isTranslateEditIconSlashed ? .black : .clear,
                            width: 55
                        )
                    }
                }
                Text("翻訳/編集")
                    .font(.caption)
                    .padding(.top, -5)
            }
            
            // 翻訳アイコン全選択/全未選択toggleボタン
            VStack(spacing: 0) {
                Button {
                    isTranslateIconSelectedAll.toggle()
                    appendOrRemoveAllSubtitles()
                } label: {
                    if isTranslateIconSelectedAll {
                        Image(systemName: "translate")
                            .font(.system(size: 13))
                            .foregroundColor(.white)
                            .padding(5)
                            .background(
                                Circle()
                                    .fill(ColorCodes.primary.color().opacity(0.7))
                                    .overlay(Circle().stroke(ColorCodes.primary.color(), lineWidth: 2))
                            )
                    } else {
                        Image(systemName: "translate")
                            .font(.system(size: 13))
                            .foregroundColor(.black)
                            .padding(5)
                            .background(Circle().stroke(Color.gray, lineWidth: 1))
                    }
                }
                .buttonStyle(PlainButtonStyle()) // ボタン枠内をタップ領域にする
                
                Text("全選択")
                    .font(.caption)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 49)
        .background(ColorCodes.primary2.color())
    }
}
