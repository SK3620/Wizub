//
//  TranslateSubtitlesRequestModel.swift
//  SwiftUIApp
//
//  Created by 鈴木 健太 on 2024/09/17.
//

struct TranslateRequestModel: Codable {
    let subtitles: [SubtitleModel.SubtitleDetailModel]
    let arrayCount: Int // 翻訳量制限判定に使用する配列の要素数
    
    enum CodingKeys: String, CodingKey {
        case subtitles
        case arrayCount = "array_count"
    }
    
    init(subtitles: [SubtitleModel.SubtitleDetailModel], arrayCount: Int) {
        self.subtitles = subtitles
        self.arrayCount = arrayCount
    }
}
