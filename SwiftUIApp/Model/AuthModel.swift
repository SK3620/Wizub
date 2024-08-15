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
    
    init(name: String, email: String, password: String, apiToken: String) {
        self.name = name
        self.email = email
        self.password = password
        self.apiToken = apiToken
    }
    
    enum CodingKeys: String, CodingKey {
        case name = "name"
        case email = "email"
        case password = "password"
        case apiToken = "api_token"
    }
}


struct AuthModel2: Codable, Identifiable {
    
    let id: Int
    let name: String
    let email: String
    let password: String
    let apiToken: String
    
    init(id: Int, name: String, email: String, password: String, apiToken: String) {
        self.id = id
        self.name = name
        self.email = email
        self.password = password
        self.apiToken = apiToken
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case name = "name"
        case email = "email"
        case password = "password"
        case apiToken = "api_token"
    }
}
