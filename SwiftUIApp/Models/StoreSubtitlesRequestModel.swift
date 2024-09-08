//
//  StoreTranscriptRequestModel.swift
//  SwiftUIApp
//
//  Created by 鈴木 健太 on 2024/09/02.
//

struct StoreSubtitlesRequestModel: Codable {
    let videoId: String
    let title: String
    let thumbnailUrl: String
    let subtitles: [SubtitleModel.SubtitleDetailModel]
    
    enum CodingKeys: String, CodingKey {
        case videoId = "video_id"
        case title
        case thumbnailUrl = "thumbnail_url"
        case subtitles
    }
    
    init(videoId: String, title: String, thumbnailUrl: String, subtitles: [SubtitleModel.SubtitleDetailModel]) {
        self.videoId = videoId
        self.title = title
        self.thumbnailUrl = thumbnailUrl
        self.subtitles = subtitles
    }
}
