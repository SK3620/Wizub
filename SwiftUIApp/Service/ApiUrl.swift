//
//  ApiUrl.swift
//  SwiftUIApp
//
//  Created by 鈴木 健太 on 2024/08/14.
//

struct ApiUrl {
    
    static var baseUrl: String {
        #if DEVELOP
        return "http://localhost:8000"
        #endif
        return "http〜〜"
    }
    
    // YouTubeDataAPI V3
    static var youTubeBaseUrl: String {
        #if DEVELOP
        return "https://www.googleapis.com/youtube/v3/search"
        #endif
        return "http〜〜"
    }
    
    // サインアップ post
    static let signUpUrl = "/api/sign_up"

    // サインイン post
    static let signInUrl = "/api/sign_in"
    
    // Email重複チェック post
    static let checkEmailUrl = "api/check_email"
    
    // 選択した動画の英語字幕情報取得 get
    static let getTranscript = "api/get_transcript"

    // なし
    static let none = ""
}
