//
//  CheckEmailRequest.swift
//  SwiftUIApp
//
//  Created by 鈴木 健太 on 2024/08/15.
//

import Foundation
import Alamofire

struct checkEmail: CommonHttpRouter {
    
    typealias Response = AuthModel
    var path: String { return ApiUrl.checkEmailUrl }
    var method: HTTPMethod { return .post }
    
    func body() throws -> Data? {
        try JSONEncoder().encode(["email": email])
    }
    
    private let email: String
    
    init(model: AuthModel) {
        self.email = model.email
    }
}
