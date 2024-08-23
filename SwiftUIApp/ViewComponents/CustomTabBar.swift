//
//  BottomTabView.swift
//  SwiftUIApp
//
//  Created by 鈴木 健太 on 2024/08/19.
//

import SwiftUI

enum Tab: CaseIterable {
    case videoList
    case history
}
// MARK: - SF Symbols Name
extension Tab {
    func symbolName() -> String {
        switch self {
        case .videoList:
            return "film"
        case .history:
            return "clock"
        }
    }
    
    func tabTitle() -> String {
        switch self {
        case .videoList:
            return "動画一覧"
        case .history:
            return "履歴"
        }
    }
}

struct CustomTabBar: View {
    
    @Binding var currentTab: Tab
    
    var body: some View {
        HStack {
            ForEach(Tab.allCases, id: \.hashValue) { tab in
                VStack {
                    Button {
                        currentTab = tab
                    } label: {
                        Image(systemName: tab.symbolName())
                            .font(.system(size: 30))
                            .frame(maxWidth: .infinity)
                            .foregroundColor(currentTab == tab ? .white : .gray)
                    }
                    
                    // 暫定でコメントアウト中
//                    Text(tab.tabTitle())
//                        .font(.system(size: 14, weight: .bold))
//                        .foregroundColor(currentTab == tab ? .white : .gray)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 49)
        .background(ColorCodes.primary.color())
    }
}
