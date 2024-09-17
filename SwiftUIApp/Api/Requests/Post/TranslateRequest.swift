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
        try JSONEncoder().encode(model)
    }
    
    private let model: TranslateRequestModel
    
    init(model: TranslateRequestModel) {
        self.model = model
    }
}
