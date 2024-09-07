//
//  APIRequestConfiguration.swift
//  SwiftUIApp
//
//  Created by 鈴木 健太 on 2024/08/13.
//

import Foundation
import Alamofire
import Combine

protocol CommonHttpRouter: URLRequestConvertible {
    
    associatedtype Response: Decodable
        
    var baseUrlString: String { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: HTTPHeaders { get }
    var parameters: Parameters? { get }
    func body() throws -> Data?
}

extension CommonHttpRouter {
        
    var baseUrlString: String { return ApiUrl.baseUrl }
    var headers: HTTPHeaders {
        return [
            "Content-Type": "application/json",
            "Accept": "application/json",
            "Authorization": "Bearer \(apiToken)"
        ]
    }
    var parameters: Parameters? { return nil }
    func body() throws -> Data? { return nil }
    
    private var apiToken: String {
        return KeyChainManager().loadCredentials(service: .apiTokenService)
    }
    
    func asURLRequest() throws -> URLRequest {
        
        var url = try baseUrlString.asURL()
        url = url.appendingPathComponent(path)

        var request = try URLRequest(url: url, method: method, headers: headers)
        
        if let parameters = parameters {
            request = try URLEncoding.queryString.encode(request, with: parameters)
        }
        
        request.httpBody = try body()
        
        return request
    }
}
