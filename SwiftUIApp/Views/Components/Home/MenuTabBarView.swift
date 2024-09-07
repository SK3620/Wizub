//
//  MenuTabBarView.swift
//  SwiftUIApp
//
//  Created by 鈴木 健太 on 2024/08/26.
//

import SwiftUI

struct MenuTabBarView: View {
    
    @Binding var isTranscriptSync: Bool
    var toggleTranslateEditIcon: () -> Void
    var changePlaybackRate: () -> Void
    var playBackRate: PlayBackRate
    var changeDisplayMode: () -> Void
    
    // 翻訳/編集アイコンボタンにスラッシュを入れるかどうか
    @State var isTranslateEditIconSlashed: Bool = true
    
    var body: some View {
        HStack(spacing: 48) {
            // 字幕同期
            VStack {
                Button(action: {
                    isTranscriptSync.toggle()
                }) {
                    Image(systemName: isTranscriptSync ? "doc.plaintext" : "doc.text.below.ecg")
                        .font(.system(size: 22, weight: .medium))
                }
                Text("字幕同期")
                    .font(.footnote)
            }
                       
            // 字幕表示モード切り替え
            /*
            VStack {
                Button(action: {
                    changeDisplayMode()
                }) {
                    Image(systemName: "textformat.size.larger")
                        .font(.system(size: 28))
                }
                Text("切り替え")
                    .font(.footnote)
            }
             */
            
            // 再生速度
            VStack {
                Button(action: {
                    changePlaybackRate()
                }) {
                    Text("\(playBackRate.toString())")
                        .font(.system(size: 23, weight: .medium))
                }
                Text("再生速度")
                    .font(.footnote)
                    .padding(.top, -14)
            }
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
                            Text("/")
                            Image(systemName: "pencil")
                                .font(.system(size: 15))
                        }
                        
                        // アイコンにスラッシュを入れる
                        if isTranslateEditIconSlashed {
                            Divider()
                                .frame(width: 55, height: 2.0)
                                .background(.blue)
                                .rotationEffect(.degrees(10))
                        }
                    }
                }
                Text("翻訳/編集")
                    .font(.footnote)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 49)
        .background(Color(CGColor(gray: 0.9, alpha: 1.0)))
    }
}
