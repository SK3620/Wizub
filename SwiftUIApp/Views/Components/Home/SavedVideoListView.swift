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
    
    var body: some View {
        VStack {
            // 非同期処理中はローディング
            if videoListViewModel.isLoading {
                VStack {
                    Spacer()
                    CommonProgressView()
                    Spacer()
                }
                // 保存された動画がない場合
            } else if videoListViewModel.isSuccess && videoListViewModel.cardViewVideoInfo.isEmpty {
                Spacer()
                Text("保存された動画がありません")
                    .foregroundColor(Color(white: 0.5))
                    .font(.headline)
                Spacer()
            } else {
                List {
                    ForEach(videoListViewModel.cardViewVideoInfo, id: \.self) { videoInfo in
                        VideoListRow(videoInfo: videoInfo)
                            .onTapGesture {
                                // StudyView()へ遷移
                                navigationPathEnv.path.append(.study(videoInfo: videoInfo))
                            }
                    }
                    .onDelete { indexSet in
                        indexSet.forEach { index in
                            // 削除する要素のIDを取得
                            guard let id = videoListViewModel.cardViewVideoInfo[index].id else { return }
                            // 削除処理をViewModelへ委譲
                            videoListViewModel.apply(event: .deleteSavedVideos(id: id))
                        }
                    }
                }
                .listStyle(.inset)
                .scrollIndicators(.hidden)
            }
        }
        .onAppear {
            // 配列を空にしてリセット
            videoListViewModel.cardViewVideoInfo = []
            videoListViewModel.isLoading = true
            // 保存した動画を取得
            videoListViewModel.apply(event: .getSavedVideos)
        }
        .alert(isPresented: $videoListViewModel.isShowError) {
            Alert(title: Text("Error"), message: Text(videoListViewModel.httpErrorMsg), dismissButton: .default(Text("OK")))
        }
    }
}

#Preview {
    SavedVideoListView()
}
