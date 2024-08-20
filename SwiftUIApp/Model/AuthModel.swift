//
//  AuthModel.swift
//  SwiftUIApp
//
//  Created by 鈴木 健太 on 2024/08/14.
//

import Foundation

struct AuthModel: Codable {
    
    let name: String
    let email: String
    let password: String
    let apiToken: String
    let isDuplicatedEmail: Bool?
    
    init(name: String, email: String, password: String, apiToken: String, isDuplicatedEmail: Bool?) {
        self.name = name
        self.email = email
        self.password = password
        self.apiToken = apiToken
        self.isDuplicatedEmail = isDuplicatedEmail
    }
    
    enum CodingKeys: String, CodingKey {
        case name
        case email
        case password
        case apiToken = "api_token"
        case isDuplicatedEmail = "is_duplicated_email"
    }
    
    // Request.Response（Decodable)型をSelfへダウンキャスト
   static func handleResponse(value: Decodable) -> Self? {
       return value as? Self
    }
}
