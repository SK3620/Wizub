//
//  DeleteSavedVideos.swift
//  SwiftUIApp
//
//  Created by 鈴木 健太 on 2024/09/02.
//

import Alamofire

struct DeleteSavedVideosRequest: CommonHttpRouter {
    
    typealias Response = EmptyModel
    
    var path: String { return ApiUrl.deleteSavedVideos }
    var method: HTTPMethod { return .delete }
    var parameters: Parameters? {
        return ["id": id]
    }
    
    // 削除する動画のレコードID（動画のIDではない）
    private let id: Int
    
    init(id: Int) {
        self.id = id
    }
}
