//
//  NavigationPathEnv.swift
//  SwiftUIApp
//
//  Created by 鈴木 健太 on 2024/08/21.
//

import Foundation
import SwiftUI

enum NavigationPath: Int {
    case auth, home, study, account, logout
    
    var toString: String {
        ["認証", "ホーム", "勉強", "アカウント", "ログアウト"][self.rawValue]
    }
    
    @ViewBuilder
    func Destination() -> some View {
        switch self {
        case .auth: AuthPickerView()
        case .home: HomeView()
        case .study: StudyView()
        case .account: EmptyView()
        case .logout: EmptyView()
        }
    }
}

class NavigationPathEnvironment: ObservableObject {
    @Published var path = [NavigationPath]()
}
