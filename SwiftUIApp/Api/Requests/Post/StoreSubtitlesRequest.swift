//
//  SaveTranscriptsRequest.swift
//  SwiftUIApp
//
//  Created by 鈴木 健太 on 2024/09/02.
//

import Alamofire

struct StoreSubtitlesRequest: CommonHttpRouter {
    typealias Response = NoneModel
    
    var path: String { return ApiUrl.storeSubtitles }
    var method: HTTPMethod { return .post }
    
    func body() throws -> Data? {
        try JSONEncoder().encode(model)
    }
    
    private let model : StoreSubtitlesRequestModel
    
    init(model: StoreSubtitlesRequestModel) {
        self.model = model
    }
}
