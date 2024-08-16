//
//  ApiService.swift
//  SwiftUIApp
//
//  Created by 鈴木 健太 on 2024/08/15.
//
import Alamofire
import Combine

protocol APIServiceType {
    
    func request<Request>(with request: Request) -> Future<Decodable, HttpError> where Request: CommonHttpRouter
}

final class APIService: APIServiceType {
    
    private let decoder: JSONDecoder = JSONDecoder()
    
    func request<Request>(with request: Request) -> Future<Decodable, HttpError> where Request: CommonHttpRouter {
        
        return Future<Decodable, HttpError> { promise in
            do {
                let urlRequest = try request.asURLRequest()
                
                do {
                    try AF.request(urlRequest)
                        .validate()
                        .responseDecodable(of: Request.Response.self, decoder: self.decoder) { response in
                            
                            guard let statusCode = response.response?.statusCode, let status = HttpStatus(rawValue: statusCode), let value = response.value else {
                                promise(.failure(HttpError.httpError))
                                return
                            }
                            
                            print("StatusCode: \(statusCode)")
                            
                            if status == .unauthorized {
                                promise(.failure(HttpError.unauthorized))
                            }
                            else if status.category == .success {
                                promise(.success(value))
                            }
                            else if status.category == .serverError {
                                promise(.failure(HttpError.serverError))
                            }
                            else {
                                promise(.failure(HttpError.serverResponse(status, response.data)))
                            }
                        }
                } catch {
                    if let nsError = error as NSError?,
                       nsError.code == HttpError.noNetwork.code {
                        promise(.failure(HttpError.noNetwork))
                    }
                    else if let nsError = error as NSError?,
                            nsError.code == HttpError.timeout.code {
                        promise(.failure(HttpError.timeout))
                    }
                    else if let httpError = error as? HttpError {
                        promise(.failure(httpError))
                    }
                    else {
                        promise(.failure(HttpError.other(error)))
                    }
                }
            } catch {
                promise(.failure(HttpError.invalidRequest))
            }
        }
    }
}
