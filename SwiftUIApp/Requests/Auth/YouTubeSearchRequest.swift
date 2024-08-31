//
//  YouTubeDataRequest.swift
//  SwiftUIApp
//
//  Created by 鈴木 健太 on 2024/08/19.
//

import Foundation
import Alamofire

struct YouTubeSearchRequest: CommonHttpRouter {
    
    typealias Response = YouTubeSearchResponseModel
    
    var baseUrlString: String { return ApiUrl.youTubeBaseUrl }
    var path: String { return ApiUrl.none }
    var method: HTTPMethod { return .get }
    var headers: HTTPHeaders {
        // YouTubeDataAPI使用時は"Authorization"は除外する
        [
        "Content-Type": "application/json",
        "Accept": "application/json",
        ]
    }
    var parameters: Parameters? {
        var parameters: [String: String] = [
            "part": "snippet",
            "q": query,
            "type": "video",
            "maxResults": "10",
            "key": Keys.youTubeDataApiKey
        ]
        
        // 追加データを取得
        if let nextPageToken = nextPageToken {
            parameters["pageToken"] = nextPageToken
        }
        
        return parameters
    }
    
    private let query: String
    private let nextPageToken: String?
    
    init(query: String, nextPageToken: String? = nil) {
        self.query = query
        self.nextPageToken = nextPageToken
    }
}
