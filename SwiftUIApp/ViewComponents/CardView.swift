//
//  CardView.swift
//  SwiftUIApp
//
//  Created by 鈴木 健太 on 2024/08/20.
//

import SwiftUI

struct CardView: View {
    
    struct VideoInfo: Identifiable {
        let id: UUID = UUID()
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
            // 左側のサムネイル画像
            AsyncImage(url: URL(string: videoInfo.thumbnailURL)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 120, height: 90)
                    .clipped()
            } placeholder: {
                Color.gray
                    .frame(width: 120, height: 90)
                    .cornerRadius(8)
            }
            .cornerRadius(8)
            
            // 右側の動画タイトル
            Text(videoInfo.title)
                .font(.headline)
                .lineLimit(2)
                .padding(.leading, 8)
            
            Spacer()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 5)
    }
}

#Preview {
    CardView(videoInfo: .init(videoId: "1", title: "「英語で雑学」人間の足の進化は神様の設計ミス", thumbnailURL: "https://i.ytimg.com/vi/YtRgWUDCzkc/default.jpg"))
}
