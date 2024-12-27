//
//  MyAppSettings.swift
//  SwiftUIApp
//
//  Created by 鈴木 健太 on 2024/12/06.
//

import Foundation

struct MyAppSettings {
    /// 問い合わせフォームURL
    public static let contactFormUrl = URL(string: "https://tayori.com/form/7c23974951b748bcda08896854f1e7884439eb5c/")
    /// プライバシーポリシーURL
    public static let privacyPolicyUrl = URL(string: "https://doc-hosting.flycricket.io/wizub-privacy-policy/b3ee24fb-2484-4d92-991f-f4ebb7c6c0fb/privacy")
    /// 利用規約URL
    public static let termsAndConditionsUrl = URL(string: "https://doc-hosting.flycricket.io/wizub-terms-of-use/1089c4ab-8b45-4e23-b1ac-86647f800a9c/terms")
    
    /// 早送り＆巻き戻し秒数
    public static let rewindFastForwardSeconds: Int = 3
}
