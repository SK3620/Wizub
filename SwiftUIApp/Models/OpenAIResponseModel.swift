//
//  OpenAIResponse.swift
//  SwiftUIApp
//
//  Created by 鈴木 健太 on 2024/08/28.
//

struct OpenAIResponseModel: Codable {
    let answer: [String: String]

    enum CodingKeys: String, CodingKey {
        case answer
    }
    
    // Request.Response（Decodable)型をSelfへダウンキャスト
    static func handleResponse(value: Decodable) -> Self? {
       return value as? Self
    }
}

struct JaTranslation: Codable, Identifiable {
    let id: Int
    let jaTranslation: String // 日本語訳
}
