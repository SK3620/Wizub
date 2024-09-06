//
//  HttpError.swift
//  SwiftUIApp
//
//  Created by 鈴木 健太 on 2024/08/16.
//

import Foundation

enum HttpError: Error, LocalizedError {
    // MARK: - Request Error cases
    // The request could not be constructed
    case invalidRequest
    // The body of the request could not be created
    case unexpectedBody

    // MARK: - Response Error cases
    // The response data did not have the expected format, value, or type
    case unexpectedResponse
    // The web service did not return valid JSON
    case jsonParsingError
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
    
    // HTTP error -1001
    case timeout

    // A network connection could not be made
    case noNetwork

    /// General HTTP Error, including the response and response data, if anything was returned
    case serverResponse(HttpStatus, Data?)
    /// General Error
    case other(Error)
    
    
    case unknown
    
    
    /// The error message returned from localizedDescription
    /*
    public var errorDescription: String? {
        #if DEVELOP
        return debugDescription
        #else
        return description
        #endif
    }
     */
    
    public var errorDescription: String? {
        return description
    }

    /// A user friendly error message
    var description: String {
        switch self {
        case .invalidRequest:
            return NSLocalizedString("リクエストが実行できませんでした。変更して再試行してください。", comment: "Invalid Request")
        case .unexpectedBody:
            return NSLocalizedString("入力に問題がありました。変更して再試行してください。", comment: "Unexpected Body")
        case .httpError:
            return NSLocalizedString("ウェブサービスがエラーを返しました。", comment: "HTTP Error")
        case .unexpectedResponse:
            return NSLocalizedString("予期しないデータが返されました。", comment: "Unexpected Response")
        case .jsonParsingError:
            return NSLocalizedString("JSONを解析できませんでした。", comment: "JSON Parsing Error")
        case .stringParsingError:
            return NSLocalizedString("文字列を解析できませんでした。", comment: "String Parsing Error")
        case .unauthorized:
            return NSLocalizedString("認証に失敗しました。もう一度サインインしてください。", comment: "Unauthorized")
        case .forbidden:
            return NSLocalizedString("このアプリにアクセス権限がありません。", comment: "Forbidden")
        case .timeout:
            return NSLocalizedString("リクエストがタイムアウトしました。", comment: "Timeout")
        case .noNetwork:
            return NSLocalizedString("ネットワーク接続を確立できませんでした。", comment: "No Network")
        case .serverError:
            return NSLocalizedString("サーバーでエラーが発生しました。もう一度試してください。", comment: "Server Error")
        case .serverResponse(let status, _):
            return NSLocalizedString("ウェブサービスがステータスコード \(status.rawValue) を返しました。", comment: "Server Response Error")
        case .other(let error):
            return NSLocalizedString("エラーが発生しました: \(error.localizedDescription)", comment: "Other Error")
        }
    }

    /// A developer friendly error message
    var debugDescription: String {
        switch self {
        case .invalidRequest:
            return NSLocalizedString("DEBUG (invalidRequest): The request could not be made. Please change and try again.", comment: "DEBUG Invalid Request")
        case .unexpectedBody:
            return NSLocalizedString("DEBUG (unexpectedBody): There was a problem with the input. Please change and try again.", comment: "DEBUG Unexpected Body")
        case .httpError:
            return NSLocalizedString("DEBUG (httpError): The web service returned an error.", comment: "DEBUG HTTP Error")
        case .unexpectedResponse:
            return NSLocalizedString("DEBUG (unexpectedResponse): The data returned was an unexpected response.", comment: "DEBUG Unexpected Response")
        case .jsonParsingError:
            return NSLocalizedString("DEBUG (jsonParsingError): The json could not be parsed.", comment: "DEBUG JSON Parsing Error")
        case .stringParsingError:
            return NSLocalizedString("DEBUG (stringParsingError): The string could not be parsed.", comment: "DEBUG String Parsing Error")
        case .unauthorized:
            return NSLocalizedString("DEBUG (unauthorized): Unauthorized, please sign in again.", comment: "DEBUG Unauthorized")
        case .forbidden:
            return NSLocalizedString("DEBUG (forbidden): You have not granted this app permission to access this data.", comment: "DEBUG Forbidden")
        case .timeout:
            return NSLocalizedString("DEBUG (timeout): The request timed out.", comment: "DEBUG Timeout")
        case .noNetwork:
            return NSLocalizedString("DEBUG (noNetwork): A network connection could not be established.", comment: "DEBUG No Network")
        case .serverError:
            return NSLocalizedString("The server encountered an error. Please try again.", comment: "Server Error")
        case .serverResponse(let status, _):
            return NSLocalizedString("DEBUG (serverResponse): The web service returned status code \(status.rawValue)", comment: "DEBUG Server Response Error")
        case .other(let error):
            return NSLocalizedString("DEBUG (other): An error occured: \(error.localizedDescription)", comment: "DEBUG Other Error")
        }
    }

    /// Code from the custom error type
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
}
