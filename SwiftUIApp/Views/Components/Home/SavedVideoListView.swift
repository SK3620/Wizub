//
//  SavedVideoListView.swift
//  SwiftUIApp
//
//  Created by 鈴木 健太 on 2024/09/02.
//

import SwiftUI

struct SavedVideoListView: View {
    
    // ナビゲーションパスの状態管理用クラス
    @EnvironmentObject var navigationPathEnv: NavigationPathEnvironment
    
    @StateObject private var videoListViewModel: VideoListViewModel = VideoListViewModel(apiService: APIService())
    
    @State var text: String = ""
    
    var body: some View {
        VStack {
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
                                // StudyView()へ遷移
                                navigationPathEnv.path.append(.study(videoInfo: videoInfo))
                            }
                            .onAppear {
                                // 最下部までスクロールされた場合、保存した追加動画を読み込む
                                if videoInfo.id == videoListViewModel.cardViewVideoInfo.last?.id {
                                   
                                }
                            }
                    }
                    .onDelete { indexSet in
                        indexSet.forEach { index in
                            // 削除する要素のIDを取得
                            guard let id = videoListViewModel.cardViewVideoInfo[index].id else { return }
                            // 削除処理をViewModelへ委譲
                            videoListViewModel.apply(inputs: .deleteSavedVideos(id: id))
                        }
                    }
                }
                .listStyle(.inset)
                .scrollIndicators(.hidden)
            }
            
            Spacer()
        }
        .onAppear {
            // 配列を空にしてリセット
            videoListViewModel.cardViewVideoInfo = []
            // 保存した動画を取得
            videoListViewModel.apply(inputs: .getSavedVideos)
        }
    }
}

#Preview {
    SavedVideoListView()
}
