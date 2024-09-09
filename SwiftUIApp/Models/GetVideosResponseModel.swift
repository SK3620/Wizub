//
//  GetSavedVideosResponseModel.swift
//  SwiftUIApp
//
//  Created by 鈴木 健太 on 2024/09/02.
//

protocol VideoProtocol {
    var id: Int? { get }
    var videoId: String { get }
    var title: String { get }
    var thumbnailUrl: String { get }
    var isVideoAlreadySaved: Bool { get }
}

struct GetVideosResponseModel: Codable {
    let items: [Video]
    
    struct Video: Codable, VideoProtocol {
        let id: Int?
        let videoId: String
        let title: String
        let thumbnailUrl: String
        let isVideoAlreadySaved: Bool
        let subtitles: [SubtitleModel.SubtitleDetailModel]
        
        enum CodingKeys: String, CodingKey {
            case id
            case videoId = "video_id"
            case title
            case thumbnailUrl = "thumbnail_url"
            case isVideoAlreadySaved = "is_video_already_saved"
            case subtitles
        }
    }
    
    // Request.Response（Decodable)型をSelfへダウンキャスト
    static func handleResponse(value: Decodable) -> Self? {
       return value as? Self
    }
}
