//
//  ApiService.swift
//  SwiftUIApp
//
//  Created by 鈴木 健太 on 2024/08/15.
//
import Alamofire
import Combine

protocol APIServiceType {
    
    func request<Request>(with request: Request) -> AnyPublisher<Decodable, HttpError> where Request: CommonHttpRouter
}

final class APIService: APIServiceType {
    
    private let decoder: JSONDecoder = JSONDecoder()
    
    func request<Request>(with request: Request) -> AnyPublisher<Decodable, HttpError> where Request: CommonHttpRouter {
        
        Deferred {
            Future<Decodable, HttpError> { promise in
                do {
                    let urlRequest = try request.asURLRequest()
                    
                    AF.request(urlRequest)
                        .validate()
                        .responseDecodable(of: Request.Response.self, decoder: self.decoder) { response in
                            
                            if let statusCode = response.response?.statusCode {
                                let status = HttpStatus(code: statusCode)
                                
                                if status.category == .success {
                                    if let value = response.value {
                                        promise(.success(value))
                                    } else {
                                        promise(.failure(.invalidResponse))
                                    }
                                    return
                                }
                                
                                if status.category == .serverError {
                                    promise(.failure(HttpError.serverError))
                                } else {
                                    promise(.failure(status.commonStatus))
                                }
                            }
                            
                            if let afError = response.error {
                                let afErrorStatus = AFErrorStatus(afError: afError)
                                promise(.failure(afErrorStatus.status))
                            } else {
                                promise(.failure(.unknown))
                            }
                        }
                } catch {
                    if let nsError = error as NSError? {
                        if nsError.code == NSURLErrorNotConnectedToInternet {
                            promise(.failure(HttpError.noNetwork))
                        } else if nsError.code == NSURLErrorTimedOut {
                            promise(.failure(HttpError.timeout))
                        } else {
                            promise(.failure(HttpError.unknown))
                        }
                    } else {
                        promise(.failure(HttpError.invalidRequest))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }
}

