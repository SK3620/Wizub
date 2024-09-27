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
    var parameters: Parameters? {
        return [
            "email": email,
            "password": password
        ]
    }
    
    private let email: String
    private let password: String
    
    init(email: String, password: String) {
        self.email = email
        self.password = password
    }
}
