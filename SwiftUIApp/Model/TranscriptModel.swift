//
//  TranscriptModel.swift
//  SwiftUIApp
//
//  Created by 鈴木 健太 on 2024/08/21.
//

import Foundation

struct TranscriptModel: Codable {
    let transcripts: [TranscriptDetailModel]
    
    enum CodingKeys: String, CodingKey {
        case transcripts
    }
    
    struct TranscriptDetailModel: Codable, Identifiable {
        let id = UUID()
        let text: String // 字幕
        let start: Double // 字幕表示開始時間
        let duration: Double // 字幕が表示されている時間の長さ
        
        enum CodingKeys: String, CodingKey {
            case text
            case start
            case duration
        }
    }
    
    // Request.Response（Decodable)型をSelfへダウンキャスト
    static func handleResponse(value: Decodable) -> Self? {
       return value as? Self
    }
}

