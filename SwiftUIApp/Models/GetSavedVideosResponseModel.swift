//
//  GetSavedVideosResponseModel.swift
//  SwiftUIApp
//
//  Created by 鈴木 健太 on 2024/09/02.
//

struct GetSavedVideosResponseModel: Codable {
    let items: [Video]
    
    enum CodingKeys: CodingKey {
        case items
    }
    
    struct Video: Codable {
        let id: Int
        let videoId: String
        let title: String
        let thumbnailUrl: String
        let transcripts: [TranscriptModel.TranscriptDetailModel]
        
        enum CodingKeys: String, CodingKey {
            case id
            case videoId = "video_id"
            case title
            case thumbnailUrl = "thumbnail_url"
            case transcripts
        }
    }
    
    // Request.Response（Decodable)型をSelfへダウンキャスト
    static func handleResponse(value: Decodable) -> Self? {
       return value as? Self
    }
}
