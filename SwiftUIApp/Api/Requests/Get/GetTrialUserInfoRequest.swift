//
//  GetTrialUserInfoRequest.swift
//  SwiftUIApp
//
//  Created by 鈴木 健太 on 2024/12/06.
//

import Foundation
import Alamofire

struct GetTrialUserInfoRequest: CommonHttpRouter {
    
    typealias Response = AuthModel
    
    var path: String { return ApiUrl.getTrialUserInfo }
    var method: HTTPMethod { return .get }
}
