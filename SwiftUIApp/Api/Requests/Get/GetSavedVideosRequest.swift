//
//  GetSavedVideoRequest.swift
//  SwiftUIApp
//
//  Created by 鈴木 健太 on 2024/09/02.
//

import Alamofire

struct GetSavedVideosRequest: CommonHttpRouter {
    
    typealias Response = GetVideosResponseModel
    
    var path: String { return ApiUrl.getSavedVideos }
    var method: HTTPMethod { return .get }
    
    init(){}
}
