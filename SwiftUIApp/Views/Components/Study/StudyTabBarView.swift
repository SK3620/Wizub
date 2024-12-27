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
            RewindFastForwardButton(
                action: rewindAction,
                playbackDirection: .rewind,
                isDisabled: isRepeating
            )
            
            // 動画停止/再開ボタン
            Button(action: {
                pauseAction()
            }) {
                Image(systemName: isPaused ? "play.circle.fill" : "pause.circle.fill")
                    .font(.system(size: 35))
                    .foregroundColor(ColorCodes.primaryBlack.color())
            }
            
            // 早送りボタン
            RewindFastForwardButton(
                action: fastForwardAction,
                playbackDirection: .fastForward,
                isDisabled: isRepeating
            )
            
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

// 巻き戻し・早送りボタン
struct RewindFastForwardButton: View {
    
    enum PlaybackDirection {
        case rewind // 巻き戻し
        case fastForward // 早送り
        
        var toImageName: String {
            switch self {
            case .rewind:
                return "gobackward"
            case .fastForward:
                return "goforward"
            }
        }
    }
    
    var action: () -> Void
    var playbackDirection: PlaybackDirection
    var isDisabled: Bool
        
    var body: some View {
        Button(action: {
            action()
        }) {
            ZStack {
                Image(systemName: playbackDirection.toImageName)
                    .font(.system(size: 22))
                    .foregroundColor(ColorCodes.primaryBlack.color())
                
                // 画像の真上に巻き戻し/早送り秒数を設置
                Text(String(MyAppSettings.rewindFastForwardSeconds))
                    .font(.caption)
                    .fontWeight(.bold)
                    .padding(.top, 2) // 微調整
            }
        }
        .disabled(isDisabled)
    }
}

