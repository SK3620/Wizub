//
//  CardView.swift
//  SwiftUIApp
//
//  Created by 鈴木 健太 on 2024/08/20.
//

import SwiftUI

struct VideoListRow: View {
    
    struct VideoInfo: Identifiable, Hashable {
        var id: Int?
        var isVideoAlradySaved: Bool
        let videoId: String
        let title: String
        let thumbnailURL: String
    }
    
    let videoInfo: VideoInfo
    
    init(videoInfo: VideoInfo) {
        self.videoInfo = videoInfo
    }
    
    var body: some View {
        HStack(alignment: .top) {
            // サムネイル画像
            if let url = URL(string: videoInfo.thumbnailURL) {
                // 非同期的に画像取得/表示
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        Color.gray
                            .frame(width: 140, height: 90)
                            .cornerRadius(8)
                    case .success(let image):
                        image
                            .resizable()
                            .frame(width: 140, height: 90)
                            .clipped()
                    case .failure:
                        Image(systemName: "photo")
                            .resizable()
                            .frame(width: 140, height: 90)
                            .cornerRadius(8)
                            .foregroundColor(.gray)
                    @unknown default:
                        EmptyView()
                    }
                }
                .cornerRadius(8)
            } else {
                Color.gray
                    .frame(width: 140, height: 90)
                    .cornerRadius(8)
            }
            
            // 右側の動画タイトル
            Text(videoInfo.title)
                .font(.headline)
                .lineLimit(3)
                .padding(.leading, 8)
        }
        .background(Color.white)
    }
}
