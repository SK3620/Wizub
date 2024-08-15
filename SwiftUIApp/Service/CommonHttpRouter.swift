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
        return HTTPHeaders([
            "Content-Type": "Application/json",
            "Accept": "application/json"
        ])
    }
    var parameters: Parameters? { return nil }
    func body() throws -> Data? { return nil }
    
    func asURLRequest() throws -> URLRequest {
        
        var url = try baseUrlString.asURL()
        url = url.appendingPathComponent(path)
        
        // ここでapiToken取得処理を行い、headersに追加する
        
        var request = try URLRequest(url: url, method: method, headers: headers)
        request.httpBody = try body()
        
        if let parameters = parameters {
            request = try URLEncoding.default.encode(request, with: parameters)
        }
        
        return request
    }
}
