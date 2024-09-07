//
//  CheckVideoAlreadySavedResponse.swift
//  SwiftUIApp
//
//  Created by 鈴木 健太 on 2024/09/03.
//

import Foundation

struct CheckVideoAlreadySavedResponseModel: Codable {
    let id: Int?
    let isVideoAlreadySaved: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case isVideoAlreadySaved = "is_video_already_saved"
    }
    
    // Request.Response（Decodable)型をSelfへダウンキャスト
    static func handleResponse(value: Decodable) -> Self? {
       return value as? Self
    }
}
