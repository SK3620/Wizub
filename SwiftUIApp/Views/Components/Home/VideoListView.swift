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
    
    // 検索値
    @State var text: String = ""
    
    // 検索初期値
    private let initialSearchText: String = "How to speak English"
    
    // 初期値による検索は１回のみ呼ぶ
    @State private var hasPerformedInitialSearch = false
    
    // 押下された動画を保持する
    @State private var tappedVideo: (CardView.VideoInfo)?
    
    var body: some View {
        VStack {
            CustomSearchBar(
                text: $text,
                onSearchButtonClick: {
                    // 一つ一つの動画情報を格納する配列をリセット
                    videoListViewModel.cardViewVideoInfo = []
                    videoListViewModel.isLoading = true
                    videoListViewModel.apply(event: .serach(text: text))
                })
            .padding([.horizontal, .bottom])
            .background(.gray.opacity(0.15))
            
            // 非同期処理中はローディング
            if videoListViewModel.isLoading {
                // 中央に表示
                VStack {
                    Spacer()
                    CommonProgressView()
                    Spacer()
                }
            } else {
                List {
                    ForEach(videoListViewModel.cardViewVideoInfo, id: \.self) { videoInfo in
                        CardView(videoInfo: videoInfo)
                            .onTapGesture {
                                // 押下された動画を保持しておく
                                tappedVideo = videoInfo
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
            if !hasPerformedInitialSearch {
                videoListViewModel.isLoading = true
                videoListViewModel.apply(event: .serach(text: initialSearchText))
                hasPerformedInitialSearch = true
            }
            
            // StudyView画面から戻ってきた時
            guard let tappedVideo = tappedVideo else { return }
            let videoId = tappedVideo.videoId
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
