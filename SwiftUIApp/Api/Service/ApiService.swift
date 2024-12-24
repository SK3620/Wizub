//
//  ApiService.swift
//  SwiftUIApp
//
//  Created by 鈴木 健太 on 2024/08/15.
//
import Alamofire
import Combine

protocol APIServiceType {
    // CommonHttpRouterに準拠したリクエストを受け取る
    // 成功時(Output) → Decodable型（デコードしたレスポンスデータ）を流す
    // 失敗時(Failure) → MyAppError型（アプリ内で扱うカスタムエラー）を流す
    func request<Request>(with request: Request) -> AnyPublisher<Decodable, MyAppError> where Request: CommonHttpRouter
}

final class APIService: APIServiceType {
    
    private let decoder: JSONDecoder = JSONDecoder()
    
    func request<Request>(with request: Request) -> AnyPublisher<Decodable, MyAppError> where Request: CommonHttpRouter {
        
        // DeferredしてFutureする（暗記）
        Deferred {
            // Future<Output → 成功, Failure → 失敗>
            // クロージャに「(Result<(any Decodable, MyAppError)>) -> Void」型であるpromiseを受け取る
            Future<Decodable, MyAppError> { promise in
                do {
                    // リクエストを組み立てる
                    let urlRequest = try request.asURLRequest()
                    
                    // AlamofireでHTTPリクエスト
                    AF.request(urlRequest)
                        .validate()
                        .responseData(completionHandler:  { [weak self] response in
                            guard let self = self else { return }
                            // リクエスト結果を場合分け
                            switch response.result {
                            case .success(let data):
                                // 成功時
                                self.handleSuccessResponse(data, promise: promise, responseType: Request.Response.self)
                            case .failure(let afError):
                                // 失敗時
                                promise(.failure(self.handleHttpErrorResponse(afError, response.data)))
                            }
                        })
                } catch {
                    promise(.failure(.invalidRequest))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    // 成功時のレスポンス処理
    private func handleSuccessResponse<T: Decodable>(_ data: Data, promise: @escaping (Result<Decodable, MyAppError>) -> Void, responseType: T.Type) where T: Decodable {
        do {
            // レスポンスデータを、CommonHttpRouterで任意に指定したレスポンス（Model）の型にデコード
            let decodedModel = try decoder.decode(responseType, from: data)
            // デコード結果を.successとして流す
            promise(.success(decodedModel))
        } catch {
            // デコード失敗時は、.failureとしてデコードエラーを流す
            promise(.failure(.responseSerializationFailed(.decodingFailed(error: error))))
        }
    }
    
    // エラーレスポンス処理
    private func handleHttpErrorResponse(_ afError: AFError, _ responseData: Data?) -> MyAppError {
        // 発生したAFErrorをアプリ独自のAFErrorType型に変換
        let afErrorType = AFErrorType(afError: afError)
        // さらに、アプリ内の全てのエラーをまとめているMyAppError型に変換しエラーハンドリングを扱いやすくする
        if let myAppError = afErrorType.toMyAppError {
            return myAppError
        }
        
        guard let responseData = responseData else {
            return .invalidResponse
        }
        
        do {
            // laravel側から送られてきた（statusCode, message, detailを持つ）カスタムエラーをデコード
            let httpErrorModel = try decoder.decode(HttpErrorModel.self, from: responseData)
            // statusCodeを元に、該当するHTTPエラー(HttpErrorType型)を取得
            let httpErrorType = HttpErrorType(code: httpErrorModel.statusCode)
            // さらに、アプリ内の全てのエラーをまとめているMyAppError型に変換しエラーハンドリングを扱いやすくする
            return httpErrorType.toMyAppError(with: httpErrorModel)
        } catch {
            // デコード失敗時は、.failureとしてデコードエラーを流す
            return .responseSerializationFailed(.decodingFailed(error: error))
        }
    }
}

