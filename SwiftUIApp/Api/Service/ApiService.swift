//
//  ApiService.swift
//  SwiftUIApp
//
//  Created by 鈴木 健太 on 2024/08/15.
//
import Alamofire
import Combine

protocol APIServiceType {
    
    func request<Request>(with request: Request) -> AnyPublisher<Decodable, MyAppError> where Request: CommonHttpRouter
}

final class APIService: APIServiceType {
    
    private let decoder: JSONDecoder = JSONDecoder()
    
    func request<Request>(with request: Request) -> AnyPublisher<Decodable, MyAppError> where Request: CommonHttpRouter {
        
        Deferred {
            Future<Decodable, MyAppError> { promise in
                do {
                    let urlRequest = try request.asURLRequest()
                    
                    AF.request(urlRequest)
                        .validate()
                        .responseData(completionHandler:  { [weak self] response in
                            guard let self = self else { return }
                            switch response.result {
                            case .success(let data):
                                self.handleSuccessResponse(data, promise: promise, responseType: Request.Response.self)
                            case .failure(let afError):
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
    private func handleSuccessResponse<T: Decodable>(_ data: Data, promise: @escaping (Result<Decodable, MyAppError>) -> Void, responseType: T.Type) {
        do {
            let decodedModel = try decoder.decode(responseType, from: data)
            promise(.success(decodedModel))
        } catch {
            promise(.failure(.responseSerializationFailed(.decodingFailed(error: error))))
        }
    }
    
    // エラーレスポンス処理
    private func handleHttpErrorResponse(_ afError: AFError, _ responseData: Data?) -> MyAppError {
        let afErrorType = AFErrorType(afError: afError)
        if let myAppError = afErrorType.toMyAppError {
            return myAppError
        }
        
        guard let responseData = responseData else {
            return .invalidResponse
        }
        
        do {
            let httpErrorModel = try decoder.decode(HttpErrorModel.self, from: responseData)
            let httpErrorType = HttpErrorType(code: httpErrorModel.statusCode)
            return httpErrorType.toMyAppError(with: httpErrorModel)
        } catch {
            return .responseSerializationFailed(.decodingFailed(error: error))
        }
    }
}

