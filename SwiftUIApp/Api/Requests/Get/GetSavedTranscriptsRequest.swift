//
//  GetSavedTrancsritpRequest.swift
//  SwiftUIApp
//
//  Created by 鈴木 健太 on 2024/09/03.
//

import Alamofire

struct GetSavedTranscritpsRequest: CommonHttpRouter {
    
    typealias Response = TranscriptModel
    
    var path: String { return ApiUrl.getSavedTranscripts }
    var method: HTTPMethod { return .get }
    var parameters: Parameters? {
        return ["video_id": videoId]
    }
    
    private let videoId: String
    
    init(videoId: String) {
        self.videoId = videoId
    }
}
