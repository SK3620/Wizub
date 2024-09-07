//
//  UpdateTranscriptRequest.swift
//  SwiftUIApp
//
//  Created by 鈴木 健太 on 2024/09/03.
//

import Alamofire

struct UpdateTranscriptRequest: CommonHttpRouter {
    
    typealias Response = NoneModel
    
    var path: String { return ApiUrl.updateTranscripts }
    var method: HTTPMethod { return .put }
    var parameters: Parameters? {
        return ["id": id]
    }
    
    func body() throws -> Data? {
        try JSONEncoder().encode(model)
    }
    
    private let id: Int
    private let model: TranscriptModel
    
    init(id: Int, model: TranscriptModel) {
        self.id = id
        self.model = model
    }
}
