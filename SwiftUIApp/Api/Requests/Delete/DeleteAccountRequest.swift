//
//  DeleteAccountRequest.swift
//  SwiftUIApp
//
//  Created by 鈴木 健太 on 2024/09/27.
//

import Alamofire

struct DeleteAccountRequest: CommonHttpRouter {
    
    typealias Response = EmptyModel
    
    var path: String { return ApiUrl.deleteAccout }
    var method: HTTPMethod { return .delete }
    
    func body() throws -> Data? {
        try JSONEncoder().encode(model)
    }
    
    private let model: AuthModel
    
    init(model: AuthModel) {
        self.model = model
    }
}
