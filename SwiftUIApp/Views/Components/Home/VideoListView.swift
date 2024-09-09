//
//  VideoListView.swift
//  SwiftUIApp
//
//  Created by 鈴木 健太 on 2024/08/20.
//

import SwiftUI
import SwiftUIIntrospect

struct VideoListView: View {
    
    // ナビゲーションパスの状態管理用クラス
    @EnvironmentObject var navigationPathEnv: NavigationPathEnvironment
    
    @StateObject private var videoListViewModel: VideoListViewModel = VideoListViewModel(apiService: APIService())
    
    var body: some View {
        VStack {
            CustomSearchBar(
                text: $videoListViewModel.text,
                onSearchButtonClick: {
                    // 一つ一つの動画情報を格納する配列をリセット
                    videoListViewModel.cardViewVideoInfo = []
                    videoListViewModel.apply(event: .serach(text: videoListViewModel.text))
                })
            .padding([.horizontal, .bottom])
            .background(.gray.opacity(0.15))
            
            // 非同期処理中はローディング
            if videoListViewModel.isLoading {
                VStack {
                    Spacer()
                    CommonProgressView()
                    Spacer()
                }
            } else {
                List {
                    ForEach(videoListViewModel.cardViewVideoInfo, id: \.self) { videoInfo in
                        VideoListRow(videoInfo: videoInfo)
                            .onTapGesture {
                                // 押下された動画を保持しておく
                                videoListViewModel.tappedVideoInfo = videoInfo
                                // StudyView()へ遷移
                                navigationPathEnv.path.append(.study(videoInfo: videoInfo))
                            }
                    }
                }
                .listStyle(.inset)
                .scrollIndicators(.hidden)
            }
            Spacer()
        }
        .onAppear {
            if !videoListViewModel.hasPerformedInitialSearch {
                videoListViewModel.apply(event: .serach(text: videoListViewModel.text))
                videoListViewModel.hasPerformedInitialSearch = true
            }
            
            // StudyView画面から戻ってきた時
            guard let tappedVideoInfo = videoListViewModel.tappedVideoInfo else { return }
            let videoId = tappedVideoInfo.videoId
            videoListViewModel.apply(event: .checkVideoAlreadySaved(videoId: videoId))
        }
        .alert(isPresented: $videoListViewModel.isShowError) {
            Alert(title: Text("Error"), message: Text(videoListViewModel.httpErrorMsg), dismissButton: .default(Text("OK")))
        }
    }
}

#Preview {
    VideoListView()
}
