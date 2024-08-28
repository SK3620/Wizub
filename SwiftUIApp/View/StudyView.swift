//
//  VideoPlayView.swift
//  SwiftUIApp
//
//  Created by 鈴木 健太 on 2024/08/21.
//

import SwiftUI
import YouTubePlayerKit
import Algorithms

struct StudyView: View {
    
    @StateObject var studyViewModel: StudyViewModel
    
    @State private var showMenuTabBar = false
    
    // リスト内で押下された動画の情報
    private let videoInfo: CardView.VideoInfo
    
    init(videoInfo: CardView.VideoInfo) {
        self.videoInfo = videoInfo
        // '_' @StateObjectプロパティラッパーのバックアップストア（内部でデータを保持している場所）にアクセス
        _studyViewModel = StateObject(wrappedValue: StudyViewModel(apiService: APIService(), youTubePlayer: YouTubePlayer(stringLiteral: "https://youtube.com/watch?v=\(videoInfo.videoId)")))
    }
    
    var body: some View {
        VStack {
            
            PlayVideoView(studyViewModel: studyViewModel)
            
            ScrollViewReader { proxy in
                if studyViewModel.transcriptDisplayMode != .hideAll {
                    List {
                        ForEach(Array(studyViewModel.transcriptDetail.enumerated()), id: \.offset){
                            index, transcript in
                            TranscriptListView(
                                transcriptDetailModel: transcript,
                                isHighlighted: studyViewModel.currentTranscriptIndex == index, displayMode: studyViewModel.transcriptDisplayMode
                            )
                            .onTapGesture {
                                // ハイライトされるtranscriptを更新
                                studyViewModel.currentTranscriptIndex = index
                                studyViewModel.seekToTranscript(at: index)
                            }
                        }
                    }
                    // transcriptのindexの変更を監視
                    .onChange(of: studyViewModel.currentTranscriptIndex, { oldIndex, newIndex in
                        if let newIndex = newIndex {
                            withAnimation {
                                // 指定のtranscriptへ自動スクロール
                                proxy.scrollTo(studyViewModel.transcriptDetail[newIndex].id, anchor: .center)
                            }
                        }
                    })
                } else {
                    // 字幕表示モードが.hideAllの場合
                    VStack {
                        Spacer()
                        Text("字幕非表示中")
                            .foregroundColor(Color(white: 0.5))
                            .font(.headline)
                        Spacer()
                    }
                }
            }
        
            
            ZStack {
                
                MenuTabBarView(
                    isTranscriptSync: $studyViewModel.isTranscriptSync,
                    changePlaybackRate: {studyViewModel.changePlayBackRate() },
                    playBackRate: studyViewModel.playBackRate,
                    changeDisplayMode: { studyViewModel.changeTranscriptDisplayMode() }
                )
                .offset(y: showMenuTabBar ? -49 : 0)
                .animation(.easeInOut(duration: 0.3), value: showMenuTabBar)
                
                StudyTabBarView(
                    showMenuTabBar: $showMenuTabBar,
                    rewindAction: { studyViewModel.rewind() },
                    pauseAction: { studyViewModel.togglePlayback() },
                    fastForwardAction: { studyViewModel.fastForward()},
                    repeatAction: { studyViewModel.startRepeat() },
                    stopRepeatAction: { studyViewModel.stopRepeat() },
                    isPaused: studyViewModel.isPaused,
                    isRepeating: studyViewModel.isRepeating
                )
                .background(.white)
            }
        }
        .onAppear {
            studyViewModel.getTranscripts(videoId: videoInfo.videoId)
        }
    }
}
