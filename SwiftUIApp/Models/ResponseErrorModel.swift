//
//  ResponseErrorModel.swift
//  SwiftUIApp
//
//  Created by 鈴木 健太 on 2024/09/14.
//

struct HttpErrorModel: Codable {
    let statusCode: Int // ステータスコード
    let message: String // エラーメッセージ
    let detail: String // 開発者用エラーメッセージ
    
    // デフォルト値を設定しておく
    init(
        statusCode: Int = 999,
        message: String = "不明なエラーが発生しました。",
        detail: String = "Unknown Error Ocurred. Detail error message is empty"
    ) {
        self.statusCode = statusCode
        self.message = message
        self.detail = detail
    }
    
    enum CodingKeys: String, CodingKey {
        case statusCode = "code"
        case message
        case detail
    }
}
