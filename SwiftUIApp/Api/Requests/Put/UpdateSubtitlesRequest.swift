//
//  UpdateTranscriptRequest.swift
//  SwiftUIApp
//
//  Created by 鈴木 健太 on 2024/09/03.
//

import Alamofire

struct UpdateSubtitlesRequest: CommonHttpRouter {
    
    typealias Response = EmptyModel
    
    var path: String { return ApiUrl.updateSubtitles }
    var method: HTTPMethod { return .put }
    var pathParameters: [String] { [String(id)] }
  
    func body() throws -> Data? {
        try JSONEncoder().encode(model)
    }
    
    private let id: Int
    private let model: SubtitleModel
    
    init(id: Int, model: SubtitleModel) {
        self.id = id
        self.model = model
    }
}
