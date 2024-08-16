//
//  MyAppError.swift
//  SwiftUIApp
//
//  Created by 鈴木 健太 on 2024/08/13.
//

import Foundation

enum MyAppError: LocalizedError {
    
    enum InputValidation: String {
        case missingUsername = "Username is missing"
        case missingEmail = "Email is missing"
        case invalidEmail = "Email is not valid"
        case emailAlreadyUsed = "Email is already used"
        case missingPassword = "Password is missing"
        case invalidPassword = "8-16 chars with letters and numbers"
        case noError = ""
    }
    
    enum Account: LocalizedError {
        case noAccountWithSpecifiedId
        case alreadyRegistered(_ username: String)
        case failedToGetInfo

        var errorDescription: String? {
            switch self {
            case .noAccountWithSpecifiedId:
                return "No account with the specified ID was found."
            case .alreadyRegistered(let username):
                return "Account (@\(username)) is already registered."
            case .failedToGetInfo:
                return "Failed to get account info."
            }
        }
    }

    enum Auth: LocalizedError {
        case missingUsername
        case missingEmail
        case invalidEmail
        case emailAlreadyUsed
        case missingPassword
        case invalidPassword
        case invalidData
        case invalidJson
        case invalidCallbackURL
        case failedToStartSession
        case failedToGetParameters
        case noError

        var errorDescription: String? {
            switch self {
            case .missingUsername:
                return "Username is missing"
            case .missingEmail:
                return "Email is missing"
            case .invalidEmail:
                return "Email is not valid"
            case .emailAlreadyUsed:
                return "Email is already used"
            case .missingPassword:
                return "Password is missing"
            case .invalidPassword:
                return "8-16 chars with letters and numbers"
            case .invalidData:
                return "Data is invalid"
            case .invalidJson:
                return "The format is wrong"
            case .invalidCallbackURL:
                return "Could not get the callbackURL."
            case .failedToStartSession:
                return "Failed to start session."
            case .failedToGetParameters:
                return "Failed to get parameters."
            case .noError:
                return ""
            }
        }
    }

    enum AttachedFile: LocalizedError {
        case broken(_ filename: String)
        case notSupported(_ fileExtension: String)
        case exceeded

        var errorDescription: String? {
            switch self {
            case .broken(let fileName):
                return "Attached file: \(fileName) may be broken."
            case .notSupported(let fileExtension):
                return "MyApp does not support \(fileExtension) format."
            case .exceeded:
                return "The number of files you can attach is exceeded."
            }
        }
    }

    case account(_ detail: Account)
    case auth(_ detail: Auth)
    case attachedFile(_ detail: Auth)

    var errorDescription: String? {
        switch self {
        case .account(let detail):
            return detail.errorDescription
        case .auth(let detail):
            return detail.errorDescription
        case .attachedFile(let detail):
            return detail.errorDescription
        }
    }
}

class ErrorHandler {
    
    static func handle(_ error: Error) {
        if let myAppError = error as? MyAppError {
            switch myAppError {
            case .auth(let authError):
                print("Auth Error: \(authError.localizedDescription)")
                // エラーメッセージをユーザーに表示するための処理
            case .account(let accountError):
                print("Account Error: \(accountError.localizedDescription)")
                // エラーメッセージをユーザーに表示するための処理
            case .attachedFile(let fileError):
                print("File Error: \(fileError.localizedDescription)")
                // エラーメッセージをユーザーに表示するための処理
            }
        } else {
            // 予期しないエラーの場合の処理
            print("Unexpected error: \(error.localizedDescription)")
        }
    }
}
