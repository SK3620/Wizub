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
    
    // サインアップ post
    static let signUpUrl = "/api/sign_up"

    // サインイン post
    static let signInUrl = "/api/sign_in"
    
    // Email重複チェック post
    static let checkEmailUrl = "api/check_email"
    
    // YouTube動画検索 get
    static let searchVideos = "api/search"
    
    // DBに保存したYouTube動画取得 get
    static let getSavedVideos = "api/get_saved_videos"
        
    // DBに保存したYouTube動画削除 delete
    static let deleteSavedVideos = "api/delete_saved_videos"
    
    // DBに保存した字幕情報取得
    static let getSavedSubtitles = "api/get_saved_subtitles"
    
    // 選択した動画の字幕情報取得 get
    static let getSubtitles = "api/get_subtitles"
    
    // 字幕翻訳 get
    static let translateSubtitles = "api/get_open_ai_answer"
    
    // 動画情報と字幕の保存 post
    static let storeSubtitles = "api/store_subtitles"
    
    // 動画がすでに保存済みか否か
    static let checkVideoAlreadySaved = "api/check_video_already_saved"
    
    // 字幕更新 put
    static let updateSubtitles = "api/update_subtitles"

    // なし
    static let none = ""
}