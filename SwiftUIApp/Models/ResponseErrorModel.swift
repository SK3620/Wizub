//
//  ResponseErrorModel.swift
//  SwiftUIApp
//
//  Created by 鈴木 健太 on 2024/09/14.
//

struct ResponseErrorModel: Codable {
    let statusCode: Int // ステータスコード
    let message: String // エラーメッセージ
    let detail: String // 開発者用エラーメッセージ
    
    enum CodingKeys: String, CodingKey {
        case statusCode = "code"
        case message
        case detail
    }
}
