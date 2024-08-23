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
    
    @StateObject var studyViewModel = StudyViewModel(apiService: APIService(), url: "https://youtube.com/watch?v=NaqB5zYGEsw")
        
    var body: some View {
        VStack {
            
            PlayVideoView(studyViewModel: studyViewModel)
            
            ScrollViewReader { proxy in
                List {
                    ForEach(Array(studyViewModel.transcriptDetail.enumerated()), id: \.offset){
                        index, transcript in
                        TranscriptListView(
                            transcriptDetailModel: transcript,
                            isHighlighted: studyViewModel.currentTranscriptIndex == index
                        )
                        .onTapGesture {
                            studyViewModel.seekToTranscript(at: index)
                            // ハイライトされるtranscriptを更新
                            studyViewModel.currentTranscriptIndex = index
                        }
                    }
                }
                // transcriptのindexの変更を監視
                .onChange(of: studyViewModel.currentTranscriptIndex, { oldIndex, newIndex in
                    if let newIndex = newIndex {
                        withAnimation {
                            // 指定のtranscriptへ自動スクロール
                            proxy.scrollTo(studyViewModel.transcriptDetail[newIndex].id, anchor: .top)
                        }
                    }
                })
                // 暫定で以下の動画IDの字幕取得
                .onAppear {
                    studyViewModel.getTranscripts(videoId: "NaqB5zYGEsw")
                }
            }
            
            StudyTabBarView(
                rewindAction: { studyViewModel.rewind() },
                pauseAction: { studyViewModel.togglePlayback() },
                fastForwardAction: { studyViewModel.fastForward()},
                isPaused: studyViewModel.isPaused
            )
        }
    }
}

#Preview {
    StudyView()
}
