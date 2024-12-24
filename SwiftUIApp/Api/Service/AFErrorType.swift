//
//  AFErrorStatus.swift
//  SwiftUIApp
//
//  Created by 鈴木 健太 on 2024/09/07.
//

import Alamofire

enum AFErrorType: Error {
    // アプリに必要最低限のAlamofireエラーのみを扱う
    // Alamofireが提供するAFErrorをアプリ固有のエラー型AFErrorTypeに変換し扱いやすくする
    case createURLRequestFailed(Error)
    case invalidURL(URL)
    case parameterEncoderFailed(AFError.ParameterEncoderFailureReason)
    case responseValidationFailed(AFError.ResponseValidationFailureReason)
    case responseSerializationFailed(AFError.ResponseSerializationFailureReason)
    case sessionInvalidated(Error?)
    case sessionTaskFailed(Error)
    case other
    
    init(afError: AFError) {
        // 発生したAFErrorの種類に応じて適切なケースに設定
        switch afError {
        case .createURLRequestFailed(let error):
            self = .createURLRequestFailed(error)
        case .invalidURL(let url):
            self = .invalidURL(url as! URL)
        case .parameterEncoderFailed(let reason):
            self = .parameterEncoderFailed(reason)
        case .responseValidationFailed(let reason):
            self = .responseValidationFailed(reason)
        case .responseSerializationFailed(let reason):
            self = .responseSerializationFailed(reason)
        case .sessionInvalidated(let error):
            self = .sessionInvalidated(error)
        case .sessionTaskFailed(let error):
            self = .sessionTaskFailed(error)
        default:
            self = .other
        }
    }
    
    // アプリ内で発生するAFError以外のエラーも含めて、すべてを一つにまとめているMyAppError型に変換する
    var toMyAppError: MyAppError? {
        switch self {
            
        // URLリクエストの作成に失敗した場合
        case .createURLRequestFailed(let error):
            return .createURLRequestFailed(error)
            
        // 無効なURLが指定された場合
        case .invalidURL(let url):
            return .invalidURL(url)
            
        // パラメータエンコーディング失敗
        case .parameterEncoderFailed(let reason):
            return .parameterEncoderFailed(reason)
            
        // 4xx, 5xxを捕捉 laravel側のカスタムエラーを受け取れないため、nilを返し後続の処理に進む
        case .responseValidationFailed:
            return nil
            
        // データ変換失敗
        case .responseSerializationFailed(let reason):
            return .responseSerializationFailed(reason)
            
        // セッションタイムアウト（タイムアウトエラー）
        case .sessionInvalidated(let error):
            return .sessionInvalidated(error)
            
        // ネットワークエラー
        case .sessionTaskFailed(let error):
            return .sessionTaskFailed(error)
            
        // その他必要最低限以外のエラーは捕捉する必要がない種類のエラーのためnilを返し後続の処理に進む
        case .other:
            return nil
        }
    }
}
