//
//  StudyTabBarView.swift
//  SwiftUIApp
//
//  Created by 鈴木 健太 on 2024/08/22.
//

import SwiftUI

struct StudyTabBarView: View {
        
    var showMenuTabBar: () -> Void
    var rewindAction: () -> Void
    var pauseAction: () -> Void
    var fastForwardAction: () -> Void
    var repeatAction: () -> Void
    var stopRepeatAction: () -> Void
    var isPaused: Bool
    var isRepeating: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            
            Spacer()
            
            // リピートボタン
            Button(action: {
                if isRepeating {
                    stopRepeatAction()
                } else {
                    repeatAction()
                }
            }) {
                ZStack {
                    Image(systemName: "repeat")
                        .font(.system(size: 24))
                        .foregroundColor(ColorCodes.primaryBlack.color())
                    
                    // アイコンにスラッシュを入れる
                    CommonSlashDivider(
                        color: isRepeating ? .clear : ColorCodes.primaryBlack.color(),
                        width: 55
                    )
                }
            }
            
            Spacer()
            
            // 巻き戻しボタン
            Button(action: {
                rewindAction()
            }) {
                Image(systemName: "gobackward.5")
                    .font(.system(size: 22))
                    .foregroundColor(ColorCodes.primaryBlack.color())
            }
            .disabled(isRepeating ? true : false) // リピート中は非活性
            
            // 動画停止/再開ボタン
            Button(action: {
                pauseAction()
            }) {
                Image(systemName: isPaused ? "play.circle.fill" : "pause.circle.fill")
                    .font(.system(size: 35))
                    .foregroundColor(ColorCodes.primaryBlack.color())
            }
            
            // 早送りボタン
            Button(action: {
                fastForwardAction()
            }) {
                Image(systemName: "goforward.5")
                    .font(.system(size: 22))
                    .foregroundColor(ColorCodes.primaryBlack.color())
            }
            .disabled(isRepeating ? true : false) // リピート中は非活性
            
            Spacer()
            
            // メニューボタン
            Button {
                showMenuTabBar()
            } label: {
                ZStack {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 24))
                        .foregroundColor(ColorCodes.primaryBlack.color())
                    
                    // 故意的にアイコンにスラッシュを入れ、TabのItem全体の間隔を調整
                     CommonSlashDivider(color: .clear, width: 55)
                }
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .frame(height: 49)
    }
}

struct ColorView: View {
    var body: some View {
        
        Color.gray
        
        
        Color(red: 0.9, green: 0.9, blue: 0.9)
        
        Color(red: 0.9, green: 0.9, blue: 0.9)

        
        

        Text("あああああああ")
            .foregroundColor(ColorCodes.primary.color())
        Text("あああああああ")
            .foregroundColor(Color(red: 0.45, green: 0.45, blue: 0.45)
)
        Text("あああああああ")
            .foregroundColor(.gray)
        Text("あああああああ")
            .font(.headline)
        Text("あああああああ")
            .font(.title2)
        Text("あああああああ")
            .font(.title3)
        Text("あああああああ")
            .font(.subheadline)
        Text("あああああああ")
            .font(.caption)
        
    }
}

#Preview(body: {
    ColorView()
})