//
//  PlayVideoView.swift
//  SwiftUIApp
//
//  Created by 鈴木 健太 on 2024/08/22.
//

import SwiftUI
import Combine
import YouTubePlayerKit

struct PlayVideoView: View {
    
    @ObservedObject var studyViewModel: StudyViewModel
    
    // YouTubeプレイヤーの高さ
    private let height = UIScreen.main.bounds.height * 0.23
        
    init(studyViewModel: StudyViewModel) {
        self.studyViewModel = studyViewModel
    }
    
    var body: some View {
        VStack {
            // YouTube動画表示
            YouTubePlayerView(studyViewModel.youTubePlayer) { state in
                switch state {
                case .idle: // 読み込み中
                   CommonProgressView()
                case .ready: // 動画読み込み完了
                    EmptyView()
                case .error:
                    Text(verbatim: "YouTube player couldn't be loaded")
                }
            }
            .frame(height: height) // YouTubeプレイヤーの高さを設定
        }
    }
}

