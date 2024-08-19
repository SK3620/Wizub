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
        GeometryReader { proxy in
            HStack(spacing: 0) {
                ForEach(Tab.allCases, id: \.hashValue) { tab in
                    VStack {
                        Button {
                            currentTab = tab
                        } label: {
                            Image(systemName: tab.symbolName())
                                .renderingMode(.template)
                                .resizable()
                                .font(.system(size: 20, weight: .bold))
                                .frame(width: 25, height: 25)
                                .frame(maxWidth: .infinity)
                                .foregroundColor(currentTab == tab ? .white : .gray)
                        }
                        
                        Text(tab.tabTitle())
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(currentTab == tab ? .white : .gray)
                    }
                }
            }
            .frame(maxWidth: .infinity)
        }
        .frame(height: 30)
        .padding(.bottom, 10)
        .padding([.horizontal, .top])
        .background(ColorCodes.primary.color())
    }
}
