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
    case badRequest
    
    // HTTP error 401
    case unauthorized
    
    // HTTP error 403
    case forbidden
    
    // HTTP error 405
    case methodNotAllowed
    
    // HTTP error 406
    case notAcceptable
    
    // HTTP error 408
    case requestTimeOut
    
    // The server error 500 ~ 599
    case serverError
    
    // Invalid Request
    case invalidRequest
    
    // Invaild Response
    case invalidResponse
    
    // HTTP error -1001
     case timeout

    // A network connection could not be made
    case noNetwork

    // General HTTP Error, including the response and response data, if anything was returned
    // case serverResponse(HttpStatus, Data?)
    
    // General Error
    // case other(Error)
    
    // Unknown Error
    case unknown
    
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
        case .createUploadableFailed(let error):
            return NSLocalizedString("ファイルのアップロード処理に失敗しました。", comment: "Failed to create uploadable item")
            
        case .createURLRequestFailed(let error):
            return NSLocalizedString("URLリクエストの作成に失敗しました。", comment: "Failed to create URL request")
            
        case .downloadedFileMoveFailed(let error, let url, let url2):
            return NSLocalizedString("ダウンロードしたファイルの移動に失敗しました。ファイルパス: \(url) から \(url2) への移動に問題が発生しました。", comment: "Failed to move downloaded file")
            
        case .explicitlyCancelled:
            return NSLocalizedString("操作がキャンセルされました。", comment: "Operation was explicitly cancelled")
            
        case .invalidURL(let urlConvertible):
            return NSLocalizedString("無効なURLが指定されました。URL: \(urlConvertible)", comment: "Invalid URL provided")
            
        case .multipartEncodingFailed(let multipartEncodingFailureReason):
            return NSLocalizedString("マルチパートエンコーディングに失敗しました: \(multipartEncodingFailureReason)", comment: "Multipart encoding failed")
            
        case .parameterEncodingFailed(let parameterEncodingFailureReason):
            return NSLocalizedString("パラメータエンコーディングに失敗しました: \(parameterEncodingFailureReason)", comment: "Parameter encoding failed")
            
        case .parameterEncoderFailed(let parameterEncoderFailureReason):
            return NSLocalizedString("パラメータエンコーダーに失敗しました: \(parameterEncoderFailureReason)", comment: "Parameter encoder failed")
            
        case .requestAdaptationFailed(let error):
            return NSLocalizedString("リクエストの適応に失敗しました。: \(error)", comment: "Request adaptation failed")
            
        case .requestRetryFailed(let error, let error2):
            return NSLocalizedString("リクエストの再試行に失敗しました: \(error) と \(error2)", comment: "Request retry failed")
            
        case .responseValidationFailed(let responseValidationFailureReason):
            return NSLocalizedString("レスポンスの検証に失敗しました: \(responseValidationFailureReason)", comment: "Response validation failed")
            
        case .responseSerializationFailed(let responseSerializationFailureReason):
            return NSLocalizedString("レスポンスのシリアライズに失敗しました: \(responseSerializationFailureReason)", comment: "Response serialization failed")
            
        case .serverTrustEvaluationFailed(let serverTrustFailureReason):
            return NSLocalizedString("サーバー信頼性の評価に失敗しました: \(serverTrustFailureReason)", comment: "Server trust evaluation failed")
            
        case .sessionDeinitialized:
            return NSLocalizedString("セッションが正しく初期化されていません。", comment: "Session deinitialized")
            
        case .sessionInvalidated(let error):
            return NSLocalizedString("セッションが無効化されました: \(String(describing: error))", comment: "Session invalidated")
            
        case .sessionTaskFailed(let error):
            return NSLocalizedString("セッションタスクに失敗しました: \(error)", comment: "Session task failed")
            
        case .urlRequestValidationFailed(let urlRequestValidationFailureReason):
            return NSLocalizedString("URLリクエストの検証に失敗しました: \(urlRequestValidationFailureReason)", comment: "URL request validation failed")
            
        case .badRequest:
            return NSLocalizedString("不正なリクエストです。", comment: "Bad request")
            
        case .unauthorized:
            return NSLocalizedString("認証に失敗しました。もう一度お試しください。", comment: "Unauthorized")
            
        case .forbidden:
            return NSLocalizedString("アクセスが禁止されています。", comment: "Forbidden")
            
        case .methodNotAllowed:
            return NSLocalizedString("許可されていないメソッドです。", comment: "Method not allowed")
            
        case .notAcceptable:
            return NSLocalizedString("受け入れ不可能なリクエストです。", comment: "Not acceptable")
            
        case .requestTimeOut:
            return NSLocalizedString("リクエストがタイムアウトしました。", comment: "Request timeout")
            
        case .serverError:
            return NSLocalizedString("サーバー内部でエラーが発生しました。", comment: "Server error")
            
        case .invalidRequest:
            return NSLocalizedString("無効なリクエストです。", comment: "Invalid request")
            
        case .invalidResponse:
            return NSLocalizedString("無効なレスポンスです。", comment: "Invalid resppnse")
            
        case .timeout:
            return NSLocalizedString("リクエストがタイムアウトしました。", comment: "Timeout")
            
        case .noNetwork:
            return NSLocalizedString("ネットワーク接続がありません。", comment: "No network")
            
        case .unknown:
            return NSLocalizedString("不明なエラーが発生しました。", comment: "Unknown error")
        }
    }
    
    // MARK: - Debug Descriptions
    var debugDescription: String {
        switch self {
        case .createUploadableFailed(let error):
            return "Uploadable item creation failed with error: \(error)"
            
        case .createURLRequestFailed(let error):
            return "URL request creation failed with error: \(error)"
            
        case .downloadedFileMoveFailed(let error, let url, let url2):
            return "Failed to move downloaded file from \(url) to \(url2) with error: \(error)"
            
        case .explicitlyCancelled:
            return "Operation was explicitly cancelled by the user."
            
        case .invalidURL(let urlConvertible):
            return "Invalid URL provided: \(urlConvertible)"
            
        case .multipartEncodingFailed(let multipartEncodingFailureReason):
            return "Multipart encoding failed due to reason: \(multipartEncodingFailureReason)"
            
        case .parameterEncodingFailed(let parameterEncodingFailureReason):
            return "Parameter encoding failed due to reason: \(parameterEncodingFailureReason)"
            
        case .parameterEncoderFailed(let parameterEncoderFailureReason):
            return "Parameter encoder failed due to reason: \(parameterEncoderFailureReason)"
            
        case .requestAdaptationFailed(let error):
            return "Request adaptation failed with error: \(error)"
            
        case .requestRetryFailed(let error, let error2):
            return "Request retry failed with errors: \(error) and \(error2)"
            
        case .responseValidationFailed(let responseValidationFailureReason):
            return "Response validation failed due to reason: \(responseValidationFailureReason)"
            
        case .responseSerializationFailed(let responseSerializationFailureReason):
            return "Response serialization failed due to reason: \(responseSerializationFailureReason)"
            
        case .serverTrustEvaluationFailed(let serverTrustFailureReason):
            return "Server trust evaluation failed due to reason: \(serverTrustFailureReason)"
            
        case .sessionDeinitialized:
            return "Session was deinitialized unexpectedly."
            
        case .sessionInvalidated(let error):
            return "Session was invalidated with error: \(String(describing: error))"
            
        case .sessionTaskFailed(let error):
            return "Session task failed with error: \(error)"
            
        case .urlRequestValidationFailed(let urlRequestValidationFailureReason):
            return "URL request validation failed due to reason: \(urlRequestValidationFailureReason)"
            
        case .badRequest:
            return "Bad request encountered."
            
        case .unauthorized:
            return "Unauthorized access attempt."
            
        case .forbidden:
            return "Access forbidden for the requested resource."
            
        case .methodNotAllowed:
            return "HTTP method not allowed for the requested URL."
            
        case .notAcceptable:
            return "Requested resource is not acceptable based on the Accept headers."
            
        case .requestTimeOut:
            return "Request timed out."
            
        case .serverError:
            return "Server encountered an internal error."
            
        case .invalidRequest:
            return "Request is invalid."
            
        case .invalidResponse:
            return "Response is invalid"
            
        case .timeout:
            return "Request timeout occurred."
            
        case .noNetwork:
            return "Network connection is unavailable."
            
        case .unknown:
            return "An unknown error occurred."
        }
    }

    // MARK: - Error Codes
    var code: Int {
        switch self {
//        case .unauthorized:
//            return 401
//        case .forbidden:
//            return 403
//        case .httpError:
//            return 599
        case .timeout:
            return -1001
        case .noNetwork:
            return -1009
//        case .serverResponse(let status, _):
//            return status.rawValue
//        case .other(let error as NSError):
//            return error.code
        default:
            return 499
        }
    }
}
