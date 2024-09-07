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
    static let getSavedTranscripts = "api/get_saved_transcripts"
    
    // 選択した動画の字幕情報取得 get
    static let getTranscript = "api/get_transcript"
    
    // 字幕翻訳 get
    static let translateSubtitle = "api/get_open_ai_answer"
    
    // 動画情報とトランスクリプト保存 post
    static let storeTranscripts = "api/store_transcripts"
    
    // 動画がすでに保存済みか否か
    static let checkVideoAlreadySaved = "api/check_video_already_saved"
    
    // トランスクリプト更新 put
    static let updateTranscripts = "api/update_transcripts"

    // なし
    static let none = ""
}
