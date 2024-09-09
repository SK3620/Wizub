//
//  YouTubeDataRequest.swift
//  SwiftUIApp
//
//  Created by 鈴木 健太 on 2024/08/19.
//

import Foundation
import Alamofire

struct YouTubeSearchRequest: CommonHttpRouter {
    
    typealias Response = GetVideosResponseModel
    
    var path: String { return ApiUrl.searchVideos }
    var method: HTTPMethod { return .get }
    var parameters: Parameters? {
        let parameters: [String: String] = [
            "query": query,
        ]
        
        return parameters
    }
    
    private let query: String
    
    init(query: String) {
        self.query = query
    }
}
