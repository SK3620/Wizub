//
//  StoreTranscriptRequestModel.swift
//  SwiftUIApp
//
//  Created by 鈴木 健太 on 2024/09/02.
//

struct StoreTranscriptRequestModel: Codable {
    let videoId: String
    let title: String
    let thumbnailUrl: String
    let transcripts: [TranscriptModel.TranscriptDetailModel]
    
    enum CodingKeys: String, CodingKey {
        case videoId = "video_id"
        case title
        case thumbnailUrl = "thumbnail_url"
        case transcripts
    }
    
    init(videoId: String, title: String, thumbnailUrl: String, transcripts: [TranscriptModel.TranscriptDetailModel]) {
        self.videoId = videoId
        self.title = title
        self.thumbnailUrl = thumbnailUrl
        self.transcripts = transcripts
    }
}
