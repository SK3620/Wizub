//
//  YouTubeDataRequest.swift
//  SwiftUIApp
//
//  Created by 鈴木 健太 on 2024/08/19.
//

import Foundation
import Alamofire

struct YouTubeSearchRequest: CommonHttpRouter {
    
    typealias Response = YouTubeSearchResponse
    
    var baseUrlString: String { return ApiUrl.youTubeBaseUrl }
    var path: String { return ApiUrl.none }
    var method: HTTPMethod { return .get }
    var parameters: Parameters? {
        return [
            "part": "snippet",
            "q": query,
            "type": "video",
            "maxResults": "30",
            "key": Keys.youTubeDataApiKey
        ]
    }
    
    private let query: String
    
    init(query: String) {
        self.query = query
    }
}
