//
//  APIRequestConfiguration.swift
//  SwiftUIApp
//
//  Created by 鈴木 健太 on 2024/08/13.
//

import Foundation
import Combine
import Alamofire

protocol CommonHttpRouter: URLRequestConvertible {
    
    associatedtype Response: Decodable
        
    var baseUrlString: String { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: HTTPHeaders { get }
    var pathParameters: [String] { get }
    var queryParameters: Parameters { get }
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
    var pathParameters: [String] { return [] }
    var queryParameters: Parameters { return [:] }
    func body() throws -> Data? { return nil }
    
    private var apiToken: String {
        return KeyChainManager().loadCredentials(service: .apiTokenService)
    }
    
    func asURLRequest() throws -> URLRequest {
        
        var url = try baseUrlString.asURL()
        url = url.appendingPathComponent(path)
        
        // パスパラメーターを追加
        for component in pathParameters {
            url = url.appendingPathComponent(component)
        }
        
        // クエリパラメーターを追加
        if !queryParameters.isEmpty {
            let queryString = queryParameters.map { "\($0.key)=\($0.value)" }
                .joined(separator: "&")
            let separator = url.absoluteString.contains("?") ? "&" : "?"
            url = URL(string: url.absoluteString + separator + queryString)!
        }
        
        var request = try URLRequest(url: url, method: method, headers: headers)
        
        // ボディを追加
        if method != .get { request.httpBody = try body() }
        return request
    }
}
