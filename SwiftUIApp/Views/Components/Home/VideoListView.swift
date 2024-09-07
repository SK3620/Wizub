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
    
    @State var text: String = ""
    
    // 検索初期値
    private let initialSearchText: String = "How to speak English"
    
    // 初期値による検索は１回のみ呼ぶ
    @State private var hasPerformedInitialSearch = false
    
    // 押下された動画
    @State private var tappedVideo: (CardView.VideoInfo)?
    
    var body: some View {
        VStack {
            CustomSearchBar(
                text: $text,
                onSearchButtonClick: {
                    // 一つ一つの動画情報を格納する配列をリセット
                    videoListViewModel.cardViewVideoInfo = []
                    // ローディング開始
                    videoListViewModel.statusViewModel = StatusViewModel(isLoading: true)
                    videoListViewModel.apply(inputs: .serach(text: text))
                })
            .padding([.horizontal, .bottom])
            .background(.gray.opacity(0.15))
            
            // 非同期処理中はローディング
            if videoListViewModel.statusViewModel.isLoading {
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
                            .onAppear {
                                // 最下部までスクロールされた場合、追加動画を読み込む
                                if videoInfo.id == videoListViewModel.cardViewVideoInfo.last?.id {
                                    videoListViewModel.apply(inputs: .serach(text: text))
                                }
                            }
                    }
                }
                .listStyle(.inset)
                .scrollIndicators(.hidden)
                
                /*
                ScrollView {
                    LazyVStack() {
                        // フッターにProgressViewを追加し、表示されたら追加読み込み
                        Section {
                            List {
                                ForEach(videoListViewModel.cardViewVideoInfo, id: \.self) { videoInfo in
                                    CardView(videoInfo: videoInfo)
                                        .padding([.horizontal, .top])
                                        .onTapGesture {
                                            // 押下された動画を保持しておく
                                            tappedVideo = videoInfo
                                            // StudyView()へ遷移
                                            navigationPathEnv.path.append(.study(videoInfo: videoInfo))
                                        }
                                }
                            }
                            .listStyle(.inset)
                        } footer: {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .purple))
                                .frame(height: 150)
                                .onAppear {
                                    videoListViewModel.apply(inputs: .serach(text: text))
                                }
                        }
                    }
                }
                .scrollIndicators(.hidden)
                 */
            }
            
            Spacer()
        }
        .onAppear {
            if !hasPerformedInitialSearch {
                // ローディングアイコン表示開始
                videoListViewModel.statusViewModel = StatusViewModel(isLoading: true)
                videoListViewModel.apply(inputs: .serach(text: initialSearchText))
                
                hasPerformedInitialSearch = true
             }
            
            // StudyView画面から戻ってきた時
            guard let tappedVideo = tappedVideo else { return }
            let videoId = tappedVideo.videoId
            videoListViewModel.apply(inputs: .checkVideoAlreadySaved(videoId: videoId))
        }
    }
}

#Preview {
    VideoListView()
}
