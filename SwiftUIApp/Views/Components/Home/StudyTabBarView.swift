//
//  StudyTabBarView.swift
//  SwiftUIApp
//
//  Created by 鈴木 健太 on 2024/08/22.
//

import SwiftUI

struct StudyTabBarView: View {
    
    @Binding var showMenuTabBar: Bool
    
    var rewindAction: () -> Void
    var pauseAction: () -> Void
    var fastForwardAction: () -> Void
    var repeatAction: () -> Void
    var stopRepeatAction: () -> Void
    var isPaused: Bool
    var isRepeating: Bool
    
    var body: some View {
        HStack(spacing: 24) {
            
            Spacer()
            
            // リピートボタン
            Button(action: {
                if isRepeating {
                    stopRepeatAction()
                } else {
                    repeatAction()
                }
            }) {
                Image(systemName: isRepeating ? "repeat.1" : "repeat")
                    .font(.system(size: 24))
            }
            
            Spacer()
            
            // 巻き戻しボタン
            Button(action: {
                rewindAction()
            }) {
                Image(systemName: "gobackward.5")
                    .font(.system(size: 24))
            }
            .disabled(isRepeating ? true : false) // リピート中は非活性
            
            // 動画停止/再開ボタン
            Button(action: {
                pauseAction()
            }) {
                Image(systemName: isPaused ? "play.circle.fill" : "pause.circle.fill")
                    .font(.system(size: 35))
            }
            
            // 早送りボタン
            Button(action: {
                fastForwardAction()
            }) {
                Image(systemName: "goforward.5")
                    .font(.system(size: 24))
            }
            .disabled(isRepeating ? true : false) // リピート中は非活性
            
            Spacer()
            
            // メニューボタン
            Button {
                showMenuTabBar.toggle()
            } label: {
                Image(systemName: "ellipsis.circle")
                    .font(.system(size: 24))
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .frame(height: 49)
    }
}