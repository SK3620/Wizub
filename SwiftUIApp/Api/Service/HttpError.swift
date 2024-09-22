//
//  HttpError.swift
//  SwiftUIApp
//
//  Created by 鈴木 健太 on 2024/08/16.
//

import Alamofire

enum HttpError: Error, LocalizedError {
    
    // MARK: - AFError Cases
    case createUploadableFailed(Error)
        
    case createURLRequestFailed(Error)
        
    case downloadedFileMoveFailed(Error, URL, URL)
        
    case explicitlyCancelled
        
    case invalidURL(URLConvertible)
        
    case multipartEncodingFailed(AFError.MultipartEncodingFailureReason)
        
    case parameterEncodingFailed(AFError.ParameterEncodingFailureReason)
        
    case parameterEncoderFailed(AFError.ParameterEncoderFailureReason)
        
    case requestAdaptationFailed(Error)
        
    case requestRetryFailed(Error, Error)
        
    case responseValidationFailed(AFError.ResponseValidationFailureReason)
        
    case responseSerializationFailed(AFError.ResponseSerializationFailureReason)
        
    case serverTrustEvaluationFailed(AFError.ServerTrustFailureReason)
        
    case sessionDeinitialized
        
    case sessionInvalidated(Error?)
        
    case sessionTaskFailed(Error)
        
    case urlRequestValidationFailed(AFError.URLRequestValidationFailureReason)
    
    // MARK: - Response Error cases
    
    // The response data did not have the expected format, value, or type
    // case unexpectedResponse
    
    // The web service did not return valid JSON
    // case jsonParsingError
    
    // HTTP error 400
    case badRequest(HttpErrorStatus.HttpErrorMessage)
    
    // HTTP error 401
    case unauthorized(HttpErrorStatus.HttpErrorMessage)
    
    // HTTP error 403
    case forbidden(HttpErrorStatus.HttpErrorMessage)
    
    // HTTP error 404
    case notFound(HttpErrorStatus.HttpErrorMessage)
    
    // HTTP error 405
    case methodNotAllowed(HttpErrorStatus.HttpErrorMessage)
    
    // HTTP error 406
    case notAcceptable(HttpErrorStatus.HttpErrorMessage)
    
    // HTTP error 408
    case requestTimeOut(HttpErrorStatus.HttpErrorMessage)
    
    // The server error 500 ~ 599
    case serverError(HttpErrorStatus.HttpErrorMessage)
    
    // Invalid Request
    case invalidRequest
    
    // Invaild Response
    // case invalidResponse
    
    // HTTP error -1001
    case timeout

    // A network connection could not be made
    case noNetwork

    // General HTTP Error, including the response and response data, if anything was returned
    // case serverResponse(HttpStatus, Data?)
    
    // General Error
    // case other(Error)
    
    // Unknown Error
    case unknown(HttpErrorStatus.HttpErrorMessage)
    
    // MARK: - LocalizedError Implementation
    public var errorDescription: String? {
        #if DEVELOP
        return debugDescription
        #else
        return description
        #endif
    }
    
    // MARK: - Localized Descriptions
    var description: String {
        switch self {
        case .createUploadableFailed(_):
            return NSLocalizedString("ファイルのアップロード処理に失敗しました。", comment: "Failed to create uploadable item")
            
        case .createURLRequestFailed(_):
            return NSLocalizedString("URLリクエストの作成に失敗しました。", comment: "Failed to create URL request")
            
        case .downloadedFileMoveFailed(_, _, _):
            return NSLocalizedString("ダウンロードしたファイルの移動に失敗しました。", comment: "Failed to move downloaded file")
            
        case .explicitlyCancelled:
            return NSLocalizedString("操作がキャンセルされました。", comment: "Operation was explicitly cancelled")
            
        case .invalidURL(_):
            return NSLocalizedString("無効なURLが指定されました。", comment: "Invalid URL provided")
            
        case .multipartEncodingFailed(_):
            return NSLocalizedString("マルチパートエンコーディングに失敗しました", comment: "Multipart encoding failed")
            
        case .parameterEncodingFailed(_):
            return NSLocalizedString("パラメータエンコーディングに失敗しました", comment: "Parameter encoding failed")
            
        case .parameterEncoderFailed(_):
            return NSLocalizedString("パラメータエンコーダーに失敗しました", comment: "Parameter encoder failed")
            
        case .requestAdaptationFailed(_):
            return NSLocalizedString("リクエストの適応に失敗しました", comment: "Request adaptation failed")
            
        case .requestRetryFailed:
            return NSLocalizedString("リクエストの再試行に失敗しました", comment: "Request retry failed")
            
        case .responseValidationFailed(_):
            return NSLocalizedString("レスポンスの検証に失敗しました。", comment: "Response validation failed")
            
        case .responseSerializationFailed(_):
            return NSLocalizedString("サーバーからのデータを読み込めませんでした。", comment: "Response serialization failed")
            
        case .serverTrustEvaluationFailed(_):
            return NSLocalizedString("サーバー信頼性の評価に失敗しました。", comment: "Server trust evaluation failed")
            
        case .sessionDeinitialized:
            return NSLocalizedString("セッションが正しく初期化されていません。", comment: "Session deinitialized")
            
        case .sessionInvalidated(_):
            return NSLocalizedString("セッションが無効化されました。", comment: "Session invalidated")
            
        case .sessionTaskFailed(_):
            return NSLocalizedString("通信エラーが発生しました。", comment: "Session task failed")
            
        case .urlRequestValidationFailed(_):
            return NSLocalizedString("URLリクエストの検証に失敗しました。", comment: "URL request validation failed")
            
        case .badRequest(let httpErrorMessage):
            return NSLocalizedString(httpErrorMessage.message, comment: "Bad request")
            
        case .unauthorized(let httpErrorMessage):
            return NSLocalizedString(httpErrorMessage.message, comment: "Unauthorized")
            
        case .forbidden(let httpErrorMessage):
            return NSLocalizedString(httpErrorMessage.message, comment: "Forbidden")
            
        case .notFound(let httpErrorMessage):
            return NSLocalizedString(httpErrorMessage.message, comment: "Not Found")
            
        case .methodNotAllowed(let httpErrorMessage):
            return NSLocalizedString(httpErrorMessage.message, comment: "Method not allowed")
            
        case .notAcceptable(let httpErrorMessage):
            return NSLocalizedString(httpErrorMessage.message, comment: "Not acceptable")
            
        case .requestTimeOut(let httpErrorMessage):
            return NSLocalizedString(httpErrorMessage.message, comment: "Request timeout")
            
        case .serverError(let httpErrorMessage):
            return NSLocalizedString(httpErrorMessage.message, comment: "Server error")
            
        case .invalidRequest:
            return NSLocalizedString("無効なリクエストです。", comment: "Invalid request")
            
        case .timeout:
            return NSLocalizedString("リクエストがタイムアウトしました。", comment: "Timeout")
            
        case .noNetwork:
            return NSLocalizedString("ネットワーク接続がありません。", comment: "No network")
            
        case .unknown(let httpErrorMessage):
            return NSLocalizedString(httpErrorMessage.message, comment: "Unknown error")
        }
    }
        
        // MARK: - Debug Descriptions
    var debugDescription: String {
        switch self {
        case .createUploadableFailed(let error):
               return NSLocalizedString("Uploadable item creation failed with error: \(error)", comment: "")
               
           case .createURLRequestFailed(let error):
               return NSLocalizedString("URL request creation failed with error: \(error)", comment: "")
               
           case .downloadedFileMoveFailed(let error, let url, let url2):
               return NSLocalizedString("Failed to move downloaded file from \(url) to \(url2) with error: \(error)", comment: "")
               
           case .explicitlyCancelled:
               return NSLocalizedString("Operation was explicitly cancelled by the user.", comment: "")
               
           case .invalidURL(let urlConvertible):
               return NSLocalizedString("Invalid URL provided: \(urlConvertible)", comment: "")
               
           case .multipartEncodingFailed(let multipartEncodingFailureReason):
               return NSLocalizedString("Multipart encoding failed due to reason: \(multipartEncodingFailureReason)", comment: "")
               
           case .parameterEncodingFailed(let parameterEncodingFailureReason):
               return NSLocalizedString("Parameter encoding failed due to reason: \(parameterEncodingFailureReason)", comment: "")
               
           case .parameterEncoderFailed(let parameterEncoderFailureReason):
               return NSLocalizedString("Parameter encoder failed due to reason: \(parameterEncoderFailureReason)", comment: "")
               
           case .requestAdaptationFailed(let error):
               return NSLocalizedString("Request adaptation failed with error: \(error)", comment: "")
               
           case .requestRetryFailed(let error, let error2):
               return NSLocalizedString("Request retry failed with errors: \(error) and \(error2)", comment: "")
               
           case .responseValidationFailed(let responseValidationFailureReason):
               return NSLocalizedString("Response validation failed due to reason: \(responseValidationFailureReason)", comment: "")
               
           case .responseSerializationFailed(let responseSerializationFailureReason):
               return NSLocalizedString("Response serialization failed due to reason: \(responseSerializationFailureReason)", comment: "")
               
           case .serverTrustEvaluationFailed(let serverTrustFailureReason):
               return NSLocalizedString("Server trust evaluation failed due to reason: \(serverTrustFailureReason)", comment: "")
               
           case .sessionDeinitialized:
               return NSLocalizedString("Session was deinitialized unexpectedly.", comment: "")
               
           case .sessionInvalidated(let error):
               return NSLocalizedString("Session was invalidated with error: \(String(describing: error))", comment: "")
               
           case .sessionTaskFailed(let error):
               return NSLocalizedString("Session task failed with error: \(error)", comment: "")
               
           case .urlRequestValidationFailed(let urlRequestValidationFailureReason):
               return NSLocalizedString("URL request validation failed due to reason: \(urlRequestValidationFailureReason)", comment: "")
            
        case .badRequest(let httpErrorMessage):
            return NSLocalizedString("\(httpErrorMessage.message) with detail: \(httpErrorMessage.detail)" , comment: "Bad request")
            
        case .unauthorized(let httpErrorMessage):
            return NSLocalizedString("\(httpErrorMessage.message) with detail: \(httpErrorMessage.detail)", comment: "Unauthorized")
            
        case .forbidden(let httpErrorMessage):
            return NSLocalizedString("\(httpErrorMessage.message) with detail: \(httpErrorMessage.detail)", comment: "Forbidden")
            
        case .notFound(let httpErrorMessage):
            return NSLocalizedString("\(httpErrorMessage.message) with detail: \(httpErrorMessage.detail)", comment: "Not Found")
            
        case .methodNotAllowed(let httpErrorMessage):
            return NSLocalizedString("\(httpErrorMessage.message) with detail: \(httpErrorMessage.detail)", comment: "Method not allowed")
            
        case .notAcceptable(let httpErrorMessage):
            return NSLocalizedString("\(httpErrorMessage.message) with detail: \(httpErrorMessage.detail)", comment: "Not acceptable")
            
        case .requestTimeOut(let httpErrorMessage):
            return NSLocalizedString("\(httpErrorMessage.message) with detail: \(httpErrorMessage.detail)", comment: "Request timeout")
            
        case .serverError(let httpErrorMessage):
            return NSLocalizedString("\(httpErrorMessage.message) with detail: \(httpErrorMessage.detail)", comment: "Server error")
            
        case .invalidRequest:
            return NSLocalizedString("無効なリクエストです。", comment: "Invalid request")
            
        case .timeout:
            return NSLocalizedString("リクエストがタイムアウトしました。", comment: "Timeout")
            
        case .noNetwork:
            return NSLocalizedString("ネットワーク接続がありません。", comment: "No network")
            
        case .unknown(let httpErrorMessage):
            return NSLocalizedString("\(httpErrorMessage.message) with detail: \(httpErrorMessage.detail)", comment: "Unknown error")
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
