//
//  ApiUrl.swift
//  SwiftUIApp
//
//  Created by 鈴木 健太 on 2024/08/14.
//

struct ApiUrl {
    
    static var baseUrl: String {
        #if DEVELOP
        return "http〜〜"
        #endif
        return "http〜〜"
    }
    
    static let signUpUrl = "/api/sign_up"

    static let signInUrl = "/api/sign_in"
    
    static let checkEmailUrl = "api/check_email"
}
