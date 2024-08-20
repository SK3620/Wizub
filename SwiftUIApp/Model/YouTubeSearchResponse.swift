//
//  YouTubeDataModel.swift
//  SwiftUIApp
//
//  Created by 鈴木 健太 on 2024/08/19.
//

import Foundation

struct YouTubeSearchResponse: Codable {
    let items: [Video]
    
    struct Video: Codable {
        let id: VideoID
        let snippet: Snippet
        
        struct VideoID: Codable {
            let videoId: String
        }
        
        struct Snippet: Codable {
            let title: String
            let thumbnails: Thumbnails
            
            struct Thumbnails: Codable {
                let `default`: Thumbnail
                
                struct Thumbnail: Codable {
                    let url: String
                }
            }
        }
    }
    
    // Request.Response（Decodable)型をSelfへダウンキャスト
    static func handleResponse(value: Decodable) -> Self? {
       return value as? Self
    }
}
