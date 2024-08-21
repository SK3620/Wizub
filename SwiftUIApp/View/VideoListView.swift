//
//  VideoListView.swift
//  SwiftUIApp
//
//  Created by 鈴木 健太 on 2024/08/20.
//

import SwiftUI
import SwiftUIIntrospect

struct VideoListView: View {
    
    @StateObject private var videoListViewModel: VideoListViewModel = VideoListViewModel(apiService: APIService())
    
    @State var text: String = ""
    
    var body: some View {
        VStack {
            
            CustomSearchBar(text: $text, onSearchButtonClick: {
                videoListViewModel.cardViewVideoInfo = []
                videoListViewModel.statusViewModel = StatusViewModel(isLoading: true)
                videoListViewModel.apply(inputs: .serach(text: text))
            })
            .padding([.horizontal, .bottom])
            .background(.gray.opacity(0.15))
            
            // 非同期処理中はローディング
            if videoListViewModel.statusViewModel.isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                    .scaleEffect(2.5)
                    .padding()
            } else {
                ScrollView {
                    LazyVStack() {
                        // フッターにProgressViewを追加し、表示されたら追加読み込み
                        Section {
                            ForEach(videoListViewModel.cardViewVideoInfo) { videoInfo in
                                CardView(videoInfo: videoInfo)
                                    .padding([.horizontal, .top])
                            }
                        } footer: {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                                .frame(height: 150)
                                .onAppear {
                                    if videoListViewModel.shouldLoadMore {
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
    }
}

#Preview {
    VideoListView()
}
