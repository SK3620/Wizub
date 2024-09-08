//
//  GetTranscriptRequest.swift
//  SwiftUIApp
//
//  Created by 鈴木 健太 on 2024/08/21.
//

import Foundation
import Alamofire

struct GetSubtitlesRequest: CommonHttpRouter {
    
    typealias Response = SubtitleModel
    
    var path: String { return ApiUrl.getSubtitles }
    var method: HTTPMethod { return .get }
    var parameters: Parameters? {
        return ["video_id": videoId]
    }
    
    private let videoId: String
    
    init(videoId: String) {
        self.videoId = videoId
    }
}

