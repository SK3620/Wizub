//
//  NavigationPathEnv.swift
//  SwiftUIApp
//
//  Created by 鈴木 健太 on 2024/08/21.
//

import Foundation
import SwiftUI

enum NavigationPath: Hashable {
    
    case home
    case study(videoInfo: CardView.VideoInfo)
    
    var toString: String {
        switch self {
        case .home: return "ホーム"
        case .study: return "プレイ"
        }
    }
    
    @ViewBuilder
    func Destination() -> some View {
        switch self {
        case .home: HomeView()
        case .study(let videoInfo):
            StudyView(videoInfo: videoInfo)
        }
    }
}

class NavigationPathEnvironment: ObservableObject {
    @Published var path = [NavigationPath]()
}
