//
//  YouTubeDataModel.swift
//  SwiftUIApp
//
//  Created by 鈴木 健太 on 2024/08/19.
//

struct YouTubeSearchResponseModel: Codable {
    let items: [Video]
    
    enum CodingKeys: String, CodingKey {
        case items
    }
    
    struct Video: Codable {
        let id: Int?
        let videoId: String
        let title: String
        let thumbnailUrl: String
        let isVideoAlreadySaved: Bool
        
        enum CodingKeys: String, CodingKey {
            case id
            case videoId = "video_id"
            case title
            case thumbnailUrl = "thumbnail_url"
            case isVideoAlreadySaved = "is_video_already_saved"
        }
    }
    
    // Request.Response（Decodable)型をSelfへダウンキャスト
    static func handleResponse(value: Decodable) -> Self? {
       return value as? Self
    }
}
