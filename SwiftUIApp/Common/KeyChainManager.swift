//
//  storage.swift
//  SwiftUIApp
//
//  Created by 鈴木 健太 on 2024/08/17.
//

import Foundation

enum Service: String {
    case apiTokenService = "apiToken"
    case username = "username"
    case emailService = "email"
    case passwordService = "password"
}

class KeyChainManager {
    
    private let account = "SwiftUiApp"
    
    // 認証情報をキーチェーンに保存
    func saveCredentials(apiToken: String, username: String, email: String, password: String) {
        save(apiToken.data(using: .utf8)!, service: .apiTokenService, account: account)
        save(username.data(using: .utf8)!, service: .username, account: account)
        save(email.data(using: .utf8)!, service: .emailService, account: account)
        save(password.data(using: .utf8)!, service: .passwordService, account: account)
    }
    
    // 認証情報をキーチェーンから読み込み
    func loadCredentials(service: Service) -> String {
        read(service: service, account: account) ?? ""
    }
    
    // 認証情報をキーチェーンから削除
    func deleteCredentials() {
        delete(service: .apiTokenService, account: account)
        delete(service: .username, account: account)
        delete(service: .emailService, account: account)
        delete(service: .passwordService, account: account)
    }
}

extension KeyChainManager {
    
    // キーチェーンにデータを保存または更新
    private func save(_ data: Data, service: Service, account: String) {
        let query = [
            kSecValueData: data,
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service.rawValue,
            kSecAttrAccount: account,
        ] as CFDictionary
        
        let matchingStatus = SecItemCopyMatching(query, nil)
        switch matchingStatus {
        case errSecItemNotFound:
            // データが存在しない場合は保存
            SecItemAdd(query, nil)
            print("Saved data successfully")
        case errSecSuccess:
            // データが存在する場合は更新
            SecItemUpdate(query, [kSecValueData as String: data] as CFDictionary)
            print("Updated data successfully")
        default:
            print("Failed to save data to keychain")
        }
    }
    
    // キーチェーンからデータを読み込み
    private func read(service: Service, account: String) -> String? {
        let query = [
            kSecAttrService: service.rawValue,
            kSecAttrAccount: account,
            kSecClass: kSecClassGenericPassword,
            kSecReturnData: true
        ] as CFDictionary
        
        var result: AnyObject?
        SecItemCopyMatching(query, &result)
        
        if let data = result as? Data {
            return String(data: data, encoding: .utf8)
        } else {
            return nil
        }
    }
    
    // キーチェーンからデータを削除
    func delete(service: Service, account: String) {
        let query = [
            kSecAttrService: service.rawValue,
            kSecAttrAccount: account,
            kSecClass: kSecClassGenericPassword,
        ] as CFDictionary
        
        let status = SecItemDelete(query)
        if status == noErr {
            print("Data deleted successfully")
        } else {
            print("Failed to delete data")
        }
    }
}
