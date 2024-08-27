//
//  NavigationPathEnv.swift
//  SwiftUIApp
//
//  Created by 鈴木 健太 on 2024/08/21.
//

import Foundation
import SwiftUI

enum NavigationPath: Hashable {
    
    case auth
    case home
    case study(videoInfo: CardView.VideoInfo)
    case account
    case logout
    
    var toString: String {
        switch self {
        case .auth: return "認証"
        case .home: return "ホーム"
        case .study: return "勉強"
        case .account: return "アカウント"
        case .logout: return "ログアウト"
        }
    }
    
    @ViewBuilder
    func Destination() -> some View {
        switch self {
        case .auth: AuthPickerView()
        case .home: HomeView()
        case .study(let videoInfo): StudyView(videoInfo: videoInfo) // videoInfoを渡す
        case .account: EmptyView()
        case .logout: EmptyView()
        }
    }
}

class NavigationPathEnvironment: ObservableObject {
    @Published var path = [NavigationPath]()
}
