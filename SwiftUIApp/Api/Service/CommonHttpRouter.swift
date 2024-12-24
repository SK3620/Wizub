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
    
    // HTTPリクエストした結果のレスポンスの型（Model）を指定する
    // 指定した型（Model）はDecodableに準拠している必要がある
    associatedtype Response: Decodable
    
    // 固定の基本URL（"http://localhost:8000"や本番環境用URLなど）
    var baseUrlString: String { get }
    
    // 各APIエンドポイントのパス
    var path: String { get }
    
    // POST, GET, PUT, DELETE
    var method: HTTPMethod { get }
    
    // ヘッダー
    var headers: HTTPHeaders { get }
    
    // パスパラメーター
    var pathParameters: [String] { get }
    
    // クエリパラメーター
    var queryParameters: Parameters { get }
    
    // リクエストボディ
    func body() throws -> Data?
}

extension CommonHttpRouter {
    
    var baseUrlString: String { return ApiUrl.baseUrl }
    var headers: HTTPHeaders {
        return [
            "Content-Type": "application/json",
            "Accept": "application/json",
            "Authorization": "Bearer \(apiToken)" // LaravelSanctumを使用しているため、APITokenを含める
        ]
    }
    var pathParameters: [String] { return [] }
    var queryParameters: Parameters { return [:] }
    func body() throws -> Data? { return nil }
    
    // 端末に保存したAPITokenを取得
    private var apiToken: String {
        return KeyChainManager().loadCredentials(service: .apiTokenService)
    }
    
    // リクエストを組み立てる
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
        
        // 組み立てたurl, メソッド、ヘッダーを追加
        var request = try URLRequest(url: url, method: method, headers: headers)
        
        // ボディを追加
        if method != .get { request.httpBody = try body() }
        
        return request
    }
}
