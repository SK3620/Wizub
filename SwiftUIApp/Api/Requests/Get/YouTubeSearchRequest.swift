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
    
    var path: String { return ApiUrl.searchVideos }
    var method: HTTPMethod { return .get }
    var parameters: Parameters? {
        var parameters: [String: String] = [
            "query": query,
            "next_page_token": nextPageToken ?? ""
        ]
        
        return parameters
    }
    
    private let query: String
    private let nextPageToken: String?
    
    init(query: String, nextPageToken: String? = nil) {
        self.query = query
        self.nextPageToken = nextPageToken
    }
}
