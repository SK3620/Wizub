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
                videoListViewModel.statusViewModel.isLoading = true
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
                        ForEach(videoListViewModel.cardViewVideoInfo) { videoInfo in
                            CardView(videoInfo: videoInfo)
                                .padding([.horizontal, .top])
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
