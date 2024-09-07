//
//  SignUpRequest.swift
//  SwiftUIApp
//
//  Created by 鈴木 健太 on 2024/08/15.
//

import Alamofire

struct SignUpRequest: CommonHttpRouter {
    
    typealias Response = AuthModel
    var path: String { return ApiUrl.signUpUrl }
    var method: HTTPMethod { return .post }
    
    func body() throws -> Data? {
        try JSONEncoder().encode(model)
    }
    
    private let model: AuthModel
    
    init(model: AuthModel) {
        self.model = model
    }
}
