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
    var method: HTTPMethod { return .get }
    var parameters: Parameters? {
        [
            "content": content,
            "array_count": arrayCount
        ]
    }
    
    private let content: String
    private let arrayCount: Int
    
    init(content: String, arrayCount: Int) {
        self.content = content
        self.arrayCount = arrayCount
    }
}
