//
//  MyAppSettings.swift
//  SwiftUIApp
//
//  Created by 鈴木 健太 on 2024/12/06.
//

import Foundation

struct MyAppSettings {
    /// 開発者メールアドレス
    public static let developerEmail = "k.n.t11193620@gmail.com"
    
    /// お試し利用用のユーザー情報（固定）
    public static let usernameForTrial = "Nomad-Learner"
    public static let userIdForTrial = MyAppSettings.dynamicUserIdForTrial
    public static let emailForTrial = "nomad@learner.jp"
    public static let passwordForTrial = "NomadLearner1234"
    
    /// 問い合わせフォームURL
    public static let contactFormUrl = URL(string: "https://tayori.com/form/7c23974951b748bcda08896854f1e7884439eb5c/")
    /// プライバシーポリシーURL
    public static let privacyPolicyUrl = URL(string: "https://doc-hosting.flycricket.io/wizub-privacy-policy/b3ee24fb-2484-4d92-991f-f4ebb7c6c0fb/privacy")
    /// 利用規約URL
    public static let termsAndConditionsUrl = URL(string: "https://doc-hosting.flycricket.io/wizub-terms-of-use/1089c4ab-8b45-4e23-b1ac-86647f800a9c/terms")
}

extension MyAppSettings {
    /// お試し利用用のユーザーのuserId（固定）
    private static var dynamicUserIdForTrial: String {
        #if DEVELOP // 開発環境
        return "6Hlgc3PcXNVNfHJUHNjvrtGdnsd2"
        #else // 本番環境
        return "oaeQC4DAuaNm8X3dMN4p2n3xQrM2"
        #endif
    }
}
