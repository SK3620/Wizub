//
//  HttpStatus.swift
//  SwiftUIApp
//
//  Created by 鈴木 健太 on 2024/08/16.
//

import Foundation

enum HttpErrorType: Int {
    
    // MARK: - Informational
    //    case continueCode = 100
    //    case switchingProtocols = 101
    //    case processing = 102
    
    // MARK: - Success
    //    case ok = 200
    //    case created = 201
    //    case accepted = 202
    //    case nonAuthoritativeInformation = 203
    //    case noContent = 204
    //    case resetContent = 205
    //    case partialContent = 206
    //    case multiStatus = 207
    //    case alreadyReported = 208
    //    case imUsed = 226
    
    // MARK: - Redirection
    //    case multipleChoices = 300
    //    case movedPermanently = 301
    //    case found = 302
    //    case seeOther = 303
    //    case notModified = 304
    //    case useProxy = 305
    //    case switchProxy = 306
    //    case temporaryRedirect = 307
    //    case permanentRedirect = 308
    
    // MARK: - Client Error
    case badRequest = 400
    case unauthorized = 401
    //    case paymentRequired = 402
    case forbidden = 403
    case notFound = 404
    case methodNotAllowed = 405
    case notAcceptable = 406
    //    case proxyAuthenticationRequired = 407
    case requestTimeOut = 408
    //    case conflict = 409
    //    case gone = 410
    //    case lengthRequired = 411
    //    case preconditionFailed = 412
    //    case payloadTooLarge = 413
    //    case uriTooLong = 414
    //    case unsupportedMediaType = 415
    //    case rangeNotSatisfiable = 416
    //    case expectationFailed = 417
    //    case teapod = 418
    //    case misdirectedRequest = 421
    //    case unprocessableEntity = 422
    //    case locked = 423
    //    case failedDependency = 424
    //    case tooEarly = 425
    //    case upgradeRequired = 426
    //    case preconditionRequired = 428
    //    case tooManyRequests = 429
    //    case requestHeaderFieldsTooLarge = 431
    //    case unavailableForLegalReasons = 451
    
    // MARK: - Server Error
    case internalServerError = 500
    //    case notImplemented = 501
    //    case badGateway = 502
    //    case serviceUnavailable = 503
    //    case gatewayTimeOut = 504
    //    case httpVersionNotSupported = 505
    //    case variantAlsoNegotiates = 506
    //    case insufficientStorage = 507
    //    case loopDetected = 508
    //    case notExtended = 510
    //    case networkAuthenticationRequired = 511
    
    // MARK: - unknown
    case unknown = 999
    
    
    // MARK: - Categories of HTTP status codes
//    enum Category {
//        /// 100-199
//        case informational
//        /// 200-299
//        case success
//        /// 300-399
//        case redirection
//        /// 400-499
//        case clientError
//        /// 500-599
//        case serverError
//        /// Not between 100-599
//        case unknown
//    }
}

extension HttpErrorType {
          
    // MARK: - Initializer, parameter code: The HTTP response code
    init(code: Int) {
        // 引数rawValueに指定した値に対応する要素がない場合はnil(.unknown)
        if let validStatus = HttpErrorType(rawValue: code){
            self = validStatus
        } else {
            self = .unknown
        }
    }
    
    // MARK: - Public, get a kind of HTTP error
    func toMyAppError(with httpErrorModel: HttpErrorModel) -> MyAppError {
        switch self {
        case .badRequest:
            return .badRequest(httpErrorModel)
        case .unauthorized:
            return .unauthorized(httpErrorModel)
        case .forbidden:
            return .forbidden(httpErrorModel)
        case .notFound:
            return .notFound(httpErrorModel)
        case .methodNotAllowed:
            return .methodNotAllowed(httpErrorModel)
        case .notAcceptable:
            return .notAcceptable(httpErrorModel)
        case .requestTimeOut:
            return .requestTimeOut(httpErrorModel)
        case .internalServerError:
            return .serverError(httpErrorModel)
        case .unknown:
            return .unknown(HttpErrorModel())
        }
    }
    
    // MARK: - The category the status code belongs to
    /*
    var category: Category {
        let code = self.rawValue
        if code >= 100 && code < 200 {
            return .informational
        }
        else if code >= 200 && code < 300 {
            return .success
        }
        else if code >= 300 && code < 400 {
            return .redirection
        }
        else if code >= 400 && code < 500 {
            return .clientError
        }
        else if code >= 500 && code < 600 {
            return .serverError
        }
        else {
            return .unknown
        }
    }
     */
    
    // MARK: - Commonly seen status code + Unknown Error
    /*
    var commonStatus: HttpError {
        let status = self
        switch status {
        case .badRequest:
            return HttpError.badRequest
        case .unauthorized:
            return HttpError.unauthorized
        case .forbidden:
            return HttpError.forbidden
        case .methodNotAllowed:
            return HttpError.methodNotAllowed
        case .notFound:
            return HttpError.notFound
        case .notAcceptable:
            return HttpError.notAcceptable
        case .requestTimeOut:
            return HttpError.requestTimeOut
            // Sever Error
        case .internalServerError:
            return HttpError.serverError
            // Unknown
        case .unknown:
            return HttpError.unknown
        }
    }
     */
}
