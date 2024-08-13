//
//  Util.swift
//  SwiftUIApp
//
//  Created by 鈴木 健太 on 2024/08/13.
//

import Foundation

extension String {
    
    // メールアドレスの形式かどうか
    func isValidEmail() -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: self)
    }
    
    // 英字と数字を含む8文字以上のパスワード
    func isValidPassword(pattern: String = "^(?=.*?[A-Za-z])(?=.*?[0-9])[A-Za-z0-9]{8,}$") -> Bool {
        let passwordRegex = pattern
        return NSPredicate(format: "SELF MATCHES %@", passwordRegex).evaluate(with: self)
    }
    
    // 全角/半角スペースを取り除く
    func removingWhiteSpaces() -> String {
        let whiteSpaces: CharacterSet = [" ", "　"]
        return self.trimmingCharacters(in: whiteSpaces)
    }
    
    // 文字数制限
    func limited(to length: Int = 16) -> String {
        let cleanedValue = self.removingWhiteSpaces()
        if cleanedValue.count > 16 {
            return String(cleanedValue.prefix(length))
        }
        return cleanedValue
    }
}
