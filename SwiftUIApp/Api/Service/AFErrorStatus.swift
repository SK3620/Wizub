//
//  AFErrorStatus.swift
//  SwiftUIApp
//
//  Created by 鈴木 健太 on 2024/09/07.
//

import Alamofire

struct AFErrorStatus: Error {
    
    // MARK: - Property
    private var afError: AFError
    
    // MARK: - Initializer
    init(afError: AFError) {
        self.afError = afError
    }
    
    // MARK: - AFError
    var status: HttpError? {
        switch afError {
        case .createUploadableFailed(let error):
            return .createUploadableFailed(error)
        case .createURLRequestFailed(let error):
            return HttpError.createURLRequestFailed(error)
        case .downloadedFileMoveFailed(let error, let source, let destination):
            return .downloadedFileMoveFailed(error, source, destination)
        case .explicitlyCancelled:
            return .explicitlyCancelled
        case .invalidURL(let url):
            return HttpError.invalidURL(url)
        case .multipartEncodingFailed(let reason):
            return HttpError.multipartEncodingFailed(reason)
        case .parameterEncodingFailed(let reason):
            return HttpError.parameterEncodingFailed(reason)
        case .parameterEncoderFailed(let reason):
            return HttpError.parameterEncoderFailed(reason)
        case .requestAdaptationFailed(let error):
            return HttpError.requestAdaptationFailed(error)
        case .requestRetryFailed(let retryError, let originalError):
            return HttpError.requestRetryFailed(retryError, originalError)
        case .responseValidationFailed(let reason):
            return HttpError.responseValidationFailed(reason)
        case .responseSerializationFailed(let reason):
            return HttpError.responseSerializationFailed(reason)
        case .serverTrustEvaluationFailed(let reason):
            return HttpError.serverTrustEvaluationFailed(reason)
        case .sessionDeinitialized:
            return HttpError.sessionDeinitialized
        case .sessionInvalidated(let error):
            return HttpError.sessionInvalidated(error)
        case .sessionTaskFailed(let error):
            return HttpError.sessionTaskFailed(error)
        case .urlRequestValidationFailed(let reason):
            return HttpError.urlRequestValidationFailed(reason)
        }
    }
}
