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
    
    var path: String { return ApiUrl.translateSubtitle }
    var method: HTTPMethod { return .get }
    var parameters: Parameters? {
        return ["content": content]
    }
    
    private let content: String
    
    init(content: String) {
        self.content = content
    }
}
