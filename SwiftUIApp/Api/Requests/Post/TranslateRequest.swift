//
//  TranslateRequest.swift
//  SwiftUIApp
//
//  Created by 鈴木 健太 on 2024/08/28.
//

import Foundation
import Alamofire

struct TranslateRequest: CommonHttpRouter {
    
    typealias Response = OpenAIResponseModel
    
    var path: String { return ApiUrl.translateSubtitles }
    var method: HTTPMethod { return .post }
    
    func body() throws -> Data? {
        let data: [String: Any] = [
            "content": content,
            "totalSubtitlesCount": totalSubtitlesCount
        ]
        return try JSONSerialization.data(withJSONObject: data, options: [])
    }
    
    private let content: String
    private let totalSubtitlesCount: Int
    
    init(content: String, totalSubtitlesCount: Int) {
        self.content = content
        self.totalSubtitlesCount = totalSubtitlesCount
    }
}
