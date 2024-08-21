//
//  TranscriptModel.swift
//  SwiftUIApp
//
//  Created by 鈴木 健太 on 2024/08/21.
//

import Foundation

struct TranscriptDetailModel: Codable {
    let text: String
    let start: Double
    let duration: Double
    
    enum CodingKeys: String, CodingKey {
        case text
        case start
        case duration
    }
}

struct TranscriptModel: Codable {
    let transcripts: [TranscriptDetailModel]
    
    enum CodingKeys: String, CodingKey {
        case transcripts
    }
    
    // Request.Response（Decodable)型をSelfへダウンキャスト
    static func handleResponse(value: Decodable) -> Self? {
       return value as? Self
    }
}

