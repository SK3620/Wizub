//
//  TranscriptModel.swift
//  SwiftUIApp
//
//  Created by 鈴木 健太 on 2024/08/21.
//

import Foundation

struct SubtitleModel: Codable {
    var subtitles: [SubtitleDetailModel]
    
    enum CodingKeys: String, CodingKey {
        case subtitles
    }
    
    struct SubtitleDetailModel: Codable, Identifiable {
        let id: Int // DB保存時、自動インクリメントされるプライマリーキー
        let subtitleId: Int
        var enSubtitle: String // 英語字幕
        var jaSubtitle: String // 日本語字幕
        let start: Double // 字幕表示開始時間
        let duration: Double // 字幕が表示されている時間の長さ
        
        enum CodingKeys: String, CodingKey {
            case id = "id"
            case subtitleId = "subtitle_id"
            case enSubtitle = "en_subtitle"
            case jaSubtitle = "ja_subtitle"
            case start
            case duration
        }
    }
    
    // Request.Response（Decodable)型をSelfへダウンキャスト
    static func handleResponse(value: Decodable) -> Self? {
       return value as? Self
    }
}

