//
//  ApiService.swift
//  SwiftUIApp
//
//  Created by 鈴木 健太 on 2024/08/15.
//
import Alamofire
import Combine

// MARK: - APIServiceType Protocol
protocol APIServiceType {
    
    func request<Request>(with request: Request) -> AnyPublisher<Decodable, HttpError> where Request: CommonHttpRouter
}

// MARK: - APIService Implementation
final class APIService: APIServiceType {
    
    // MARK: - Properties
    private let decoder: JSONDecoder = JSONDecoder()
    
    // MARK: - Public Methods
    func request<Request>(with request: Request) -> AnyPublisher<Decodable, HttpError> where Request: CommonHttpRouter {
        
        Deferred {
            Future<Decodable, HttpError> { promise in
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
                                // クライアントサイドのエラーはAlamofire側で検知/判定
                                // HTTP通信エラーはlaravelからのレスポンスエラーで判定
                                promise(.failure(self.handleErrorResponse(afError, response.data)))
                            }
                        })
                } catch {
                    promise(.failure(self.handleRequestError(error)))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    // MARK: - Private Methods
    // 成功時のレスポンス処理
    private func handleSuccessResponse<T: Decodable>(_ data: Data, promise: @escaping (Result<Decodable, HttpError>) -> Void, responseType: T.Type) {
        do {
            let decodedModel = try decoder.decode(responseType, from: data)
            promise(.success(decodedModel))
        } catch {
            promise(.failure(.responseSerializationFailed(.decodingFailed(error: error))))
        }
    }
    
    // エラーレスポンス処理
    private func handleErrorResponse(_ afError: AFError, _ responseData: Data?) -> HttpError {
        let afErrorStatus = AFErrorStatus(afError: afError)
        if let httpError = afErrorStatus.status {
            return httpError
        }
        
        return handleServerError(responseData)
    }
    
    // サーバーエラーレスポンス処理
    private func handleServerError(_ responseData: Data?) -> HttpError {
        guard let responseData = responseData else {
            return .unknown(HttpErrorStatus.HttpErrorMessage())
        }
        
        do {
            let responseErrorModel = try decoder.decode(ResponseErrorModel.self, from: responseData)
            let status = HttpErrorStatus(rawValue: responseErrorModel.statusCode)
            let httpErrorMessage = HttpErrorStatus.HttpErrorMessage(message: responseErrorModel.message, detail: responseErrorModel.detail)
            return status?.getHttpError(httpErrorMessage: httpErrorMessage) ?? .unknown(HttpErrorStatus.HttpErrorMessage())
        } catch {
            return .responseSerializationFailed(.decodingFailed(error: error))
        }
    }
    
    // リクエストエラーハンドリング
    private func handleRequestError(_ error: Error) -> HttpError {
        let nsError = error as NSError
        switch nsError.code {
        case NSURLErrorNotConnectedToInternet:
            return HttpError.noNetwork
        case NSURLErrorTimedOut:
            return HttpError.timeout
        default:
            return HttpError.invalidRequest
        }
    }
}

