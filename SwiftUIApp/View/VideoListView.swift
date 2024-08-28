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
                ScrollView {
                    LazyVStack() {
                        // フッターにProgressViewを追加し、表示されたら追加読み込み
                        Section {
                            ForEach(videoListViewModel.cardViewVideoInfo) { videoInfo in
                                CardView(videoInfo: videoInfo)
                                    .padding([.horizontal, .top])
                                    .onTapGesture {
                                        // StudyView()へ遷移
                                        navigationPathEnv.path.append(.study(videoInfo: videoInfo))
                                    }
                            }
                        } footer: {
                            if videoListViewModel.shouldLoadMore {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .purple))
                                    .frame(height: 150)
                                    .onAppear {
                                        videoListViewModel.apply(inputs: .serach(text: text))
                                    }
                            }
                        }
                    }
                }
                .scrollIndicators(.hidden)
            }
            
            Spacer()
        }
        .onAppear {
            // ローディングアイコン表示開始
            videoListViewModel.statusViewModel = StatusViewModel(isLoading: true)
            videoListViewModel.apply(inputs: .serach(text: initialSearchText))
        }
    }
}

#Preview {
    VideoListView()
}
