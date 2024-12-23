//
//  GetSavedTrancsritpRequest.swift
//  SwiftUIApp
//
//  Created by 鈴木 健太 on 2024/09/03.
//

import Alamofire

struct GetSavedSubtitlesRequest: CommonHttpRouter {
    
    typealias Response = SubtitleModel
    
    var path: String { return ApiUrl.getSavedSubtitles }
    var method: HTTPMethod { return .get }
    var pathParameters: [String] { [videoId] }
    
    private let videoId: String
    
    init(videoId: String) {
        self.videoId = videoId
    }
}
