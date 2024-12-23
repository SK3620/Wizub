//
//  ApiUrl.swift
//  SwiftUIApp
//
//  Created by 鈴木 健太 on 2024/08/14.
//

struct ApiUrl {
    
    static var baseUrl: String {
        #if DEVELOP // 開発
        return "http://localhost:8000"
        #else// 本番
        return "https://swiftui-app-backend-40f5da201a03.herokuapp.com"
        #endif
    }
    
    // お試し利用用のユーザー情報取得
    static let getTrialUserInfo = "api/get_trial_user_info"
    
    // サインアップ post
    static let signUpUrl = "api/auth/sign_up"

    // サインイン post
    static let signInUrl = "api/auth/sign_in"
    
    // Email重複チェック post
    static let checkEmailUrl = "api/auth/check_email"
    
    // アカウント削除 delete
    static let deleteAccout = "api/auth/delete_account"
    
    // YouTube動画検索 get
    static let searchVideos = "api/videos/search"
    
    // DBに保存したYouTube動画取得 get
    static let getSavedVideos = "api/videos/saved"
        
    // DBに保存したYouTube動画削除 delete
    static let deleteSavedVideos = "api/videos"
    
    // DBに保存した字幕情報取得
    static let getSavedSubtitles = "api/subtitles/saved"
    
    // 選択した動画の字幕情報取得 get
    static let getSubtitles = "api/subtitles"
    
    // 字幕翻訳 get
    static let translateSubtitles = "api/subtitles/translate"
    
    // 動画情報と字幕の保存 post
    static let storeSubtitles = "api/subtitles"
    
    // 動画がすでに保存済みか否か
    static let checkVideoAlreadySaved = "api/videos/check"
    
    // 字幕更新 put
    static let updateSubtitles = "api/subtitles"

    // なし
    static let none = ""
}
