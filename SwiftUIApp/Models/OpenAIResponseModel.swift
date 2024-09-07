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

    // "JaTranslation"の配列に変換
    static func toOpenAIResponseModel2Array(answer: [String: String]) -> [JaTranslation] {
        return answer.map { JaTranslation(id: Int($0.key) ?? 0, jaTranslation: $0.value) }
    }
}

struct JaTranslation: Codable, Identifiable {
    let id: Int
    let jaTranslation: String // 日本語訳
}
