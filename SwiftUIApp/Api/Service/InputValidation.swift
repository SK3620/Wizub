//
//  MyAppError.swift
//  SwiftUIApp
//
//  Created by 鈴木 健太 on 2024/08/13.
//

import Foundation

enum AuthInputValidation: Error {
    
    case missingUsername
    case missingEmail
    case invalidEmail
    case emailAlreadyUsed
    case missingPassword
    case invalidPassword
    case noError
    
    // MARK: - LocalizedError Implementation
    public var errorDescription: String {
#if DEVELOP
        return debugDescription
#else
        return description
#endif
    }
    
    // MARK: - Localized Descriptions
    var description: String {
        switch self {
        case .missingUsername:
            return "ユーザー名を入力してください"
        case .missingEmail:
            return "Eメールを入力してください"
        case .invalidEmail:
            return "Eメールの形式が正しくありません"
        case .emailAlreadyUsed:
            return "すでに使用されたEメールです"
        case .missingPassword:
            return "パスワードを入力してください"
        case .invalidPassword:
            return "8〜16文字以上で英数字を含めてください"
        case .noError:
            return ""
        }
    }
    
    // MARK: - Debug Descriptions
    var debugDescription: String {
        switch self {
        case .missingUsername:
            return "ユーザー名を入力してください"
        case .missingEmail:
            return "Eメールを入力してください"
        case .invalidEmail:
            return "Eメールの形式が正しくありません"
        case .emailAlreadyUsed:
            return "すでに使用されたEメールです"
        case .missingPassword:
            return "パスワードを入力してください"
        case .invalidPassword:
            return "8〜16文字以上で英数字を含めてください"
        case .noError:
            return ""
        }
    }
}
