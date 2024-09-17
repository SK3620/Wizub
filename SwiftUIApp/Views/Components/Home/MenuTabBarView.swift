//
//  MenuTabBarView.swift
//  SwiftUIApp
//
//  Created by 鈴木 健太 on 2024/08/26.
//

import SwiftUI

struct MenuTabBarView: View {
    
    @Binding var isSubtitleSync: Bool
    var toggleTranslateEditIcon: () -> Void
    var changePlaybackRate: () -> Void
    var playBackRate: PlayBackRate
    
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
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 49)
        .background(ColorCodes.primary2.color())
    }
}
