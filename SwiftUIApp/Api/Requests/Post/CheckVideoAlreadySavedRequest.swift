//
//  CheckVideoAlreadySavedRequest.swift
//  SwiftUIApp
//
//  Created by 鈴木 健太 on 2024/09/03.
//

import Alamofire

struct CheckVideoAlreadySavedRequest: CommonHttpRouter {
    
    typealias Response = CheckVideoAlreadySavedResponseModel
    
    var path: String { return ApiUrl.checkVideoAlreadySaved }
    var method: HTTPMethod { return .post }

    func body() throws -> Data? {
        try JSONEncoder().encode(["video_id": videoId])
    }
    
    private let videoId: String
    
    init(videoId: String) {
        self.videoId = videoId
    }
}
