//
//  HttpError.swift
//  SwiftUIApp
//
//  Created by 鈴木 健太 on 2024/08/16.
//

import Alamofire

// AFError, laravel側から受け取ったカスタムエラー（HTTPError）, その他のエラーの全てのエラーをアプリ固有のMyAppErrorに集結させる
enum MyAppError: Error, LocalizedError {
    
    // MARK: - AFError Cases
    case createURLRequestFailed(Error)
                        
    case invalidURL(URLConvertible)
                        
    case parameterEncoderFailed(AFError.ParameterEncoderFailureReason)
            
    case responseSerializationFailed(AFError.ResponseSerializationFailureReason)
                        
    case sessionInvalidated(Error?)
        
    case sessionTaskFailed(Error)
    
    // MARK: - HTTP Error Cases
    
    // HTTP error 400
    case badRequest(HttpErrorModel)
    
    // HTTP error 401
    case unauthorized(HttpErrorModel)
    
    // HTTP error 403
    case forbidden(HttpErrorModel)
    
    // HTTP error 404
    case notFound(HttpErrorModel)
    
    // HTTP error 405
    case methodNotAllowed(HttpErrorModel)
    
    // HTTP error 406
    case notAcceptable(HttpErrorModel)
    
    // HTTP error 408
    case requestTimeOut(HttpErrorModel)
    
    // The server error 500 ~ 599
    case serverError(HttpErrorModel)
    
    // MARK: - Other Error Cases

    case invalidRequest
    
    case invalidResponse
        
    case unknown(HttpErrorModel)
    
    // MARK: - LocalizedError Implementation
    public var errorDescription: String? {
        #if DEVELOP // 開発
        return debugDescription
        #else // 本番
        return description
        #endif
    }
    
    // MARK: - Localized Descriptions
    var description: String {
        switch self {
        case .createURLRequestFailed(_):
            return NSLocalizedString("URLリクエストの作成に失敗しました。", comment: "Failed to create URL request")
            
        case .invalidURL(_):
            return NSLocalizedString("無効なURLが指定されました。", comment: "Invalid URL provided")
            
        case .parameterEncoderFailed(_):
            return NSLocalizedString("パラメータエンコーダーに失敗しました", comment: "Parameter encoder failed")
            
        case .responseSerializationFailed(_):
            return NSLocalizedString("データの取得に失敗しました。再度、お試しください。", comment: "Response serialization failed")
            
        case .sessionInvalidated(_):
            return NSLocalizedString("セッションが無効化されました。", comment: "Session invalidated")
            
        case .sessionTaskFailed(_):
            return NSLocalizedString("通信エラーが発生しました。", comment: "Session task failed")
            
        case .badRequest(let HttpErrorModel):
            return NSLocalizedString(HttpErrorModel.message, comment: "Bad request")
            
        case .unauthorized(let HttpErrorModel):
            return NSLocalizedString(HttpErrorModel.message, comment: "Unauthorized")
            
        case .forbidden(let HttpErrorModel):
            return NSLocalizedString(HttpErrorModel.message, comment: "Forbidden")
            
        case .notFound(let HttpErrorModel):
            return NSLocalizedString(HttpErrorModel.message, comment: "Not Found")
            
        case .methodNotAllowed(let HttpErrorModel):
            return NSLocalizedString(HttpErrorModel.message, comment: "Method not allowed")
            
        case .notAcceptable(let HttpErrorModel):
            return NSLocalizedString(HttpErrorModel.message, comment: "Not acceptable")
            
        case .requestTimeOut(let HttpErrorModel):
            return NSLocalizedString(HttpErrorModel.message, comment: "Request timeout")
            
        case .serverError(let HttpErrorModel):
            return NSLocalizedString(HttpErrorModel.message, comment: "Server error")
            
        case .invalidRequest:
            return NSLocalizedString("無効なリクエストです。", comment: "Invalid request")
            
        case .invalidResponse:
            return NSLocalizedString("無効なレスポンスです。", comment: "Invalid response")
            
        case .unknown(let HttpErrorModel):
            return NSLocalizedString(HttpErrorModel.message, comment: "Unknown error")
        }
    }
        
        // MARK: - Debug Descriptions
    var debugDescription: String {
        switch self {
            
        case .createURLRequestFailed(let error):
            return NSLocalizedString("URL request creation failed with error: \(error)", comment: "")
            
        case .invalidURL(let urlConvertible):
            return NSLocalizedString("Invalid URL provided: \(urlConvertible)", comment: "")
            
        case .parameterEncoderFailed(let parameterEncoderFailureReason):
            return NSLocalizedString("Parameter encoder failed due to reason: \(parameterEncoderFailureReason)", comment: "")
            
        case .responseSerializationFailed(let responseSerializationFailureReason):
            return NSLocalizedString("Response serialization failed due to reason: \(responseSerializationFailureReason)", comment: "")
            
        case .sessionInvalidated(let error):
            return NSLocalizedString("Session was invalidated with error: \(String(describing: error))", comment: "")
            
        case .sessionTaskFailed(let error):
            return NSLocalizedString("Session task failed with error: \(error)", comment: "")
            
        case .badRequest(let HttpErrorModel):
            return NSLocalizedString("\(HttpErrorModel.message) with detail: \(HttpErrorModel.detail)" , comment: "Bad request")
            
        case .unauthorized(let HttpErrorModel):
            return NSLocalizedString("\(HttpErrorModel.message) with detail: \(HttpErrorModel.detail)", comment: "Unauthorized")
            
        case .forbidden(let HttpErrorModel):
            return NSLocalizedString("\(HttpErrorModel.message) with detail: \(HttpErrorModel.detail)", comment: "Forbidden")
            
        case .notFound(let HttpErrorModel):
            return NSLocalizedString("\(HttpErrorModel.message) with detail: \(HttpErrorModel.detail)", comment: "Not Found")
            
        case .methodNotAllowed(let HttpErrorModel):
            return NSLocalizedString("\(HttpErrorModel.message) with detail: \(HttpErrorModel.detail)", comment: "Method not allowed")
            
        case .notAcceptable(let HttpErrorModel):
            return NSLocalizedString("\(HttpErrorModel.message) with detail: \(HttpErrorModel.detail)", comment: "Not acceptable")
            
        case .requestTimeOut(let HttpErrorModel):
            return NSLocalizedString("\(HttpErrorModel.message) with detail: \(HttpErrorModel.detail)", comment: "Request timeout")
            
        case .serverError(let HttpErrorModel):
            return NSLocalizedString("\(HttpErrorModel.message) with detail: \(HttpErrorModel.detail)", comment: "Server error")
            
        case .invalidRequest:
            return NSLocalizedString("Request is invalid.", comment: "Invalid request")
            
        case .invalidResponse:
            return NSLocalizedString("Response is invalid.", comment: "Invalid response")
            
        case .unknown(let HttpErrorModel):
            return NSLocalizedString("\(HttpErrorModel.message) with detail: \(HttpErrorModel.detail)", comment: "Unknown error")
        }
    }

    // MARK: - Error Codes
    /*
    var code: Int {
        switch self {
        case .unauthorized:
            return 401
        case .forbidden:
            return 403
        case .httpError:
            return 599
        case .timeout:
            return -1001
        case .noNetwork:
            return -1009
        case .serverResponse(let status, _):
            return status.rawValue
        case .other(let error as NSError):
            return error.code
        default:
            return 499
        }
    }
     */
}
