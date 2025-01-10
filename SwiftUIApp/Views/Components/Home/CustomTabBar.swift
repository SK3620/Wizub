//
//  BottomTabView.swift
//  SwiftUIApp
//
//  Created by 鈴木 健太 on 2024/08/19.
//

import SwiftUI

enum Tab: CaseIterable {
    case videoList
    case practice
}
// MARK: - SF Symbols Name
extension Tab {
    func symbolName() -> String {
        switch self {
        case .videoList:
            return "film"
        case .practice:
            return "pencil.and.list.clipboard"
        }
    }
    
    func tabTitle() -> String {
        switch self {
        case .videoList:
            return "動画一覧"
        case .practice:
            return "保存済み"
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
                        VStack(spacing: 4) {
                            Image(systemName: tab.symbolName())
                                .font(.system(size: 26))
                                .frame(maxWidth: .infinity)
                                .foregroundColor(currentTab == tab ? .white : .gray)
                            
                            Text(tab.tabTitle())
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(currentTab == tab ? .white : .gray)
                        }
                    }
                }
                .buttonStyle(PlainButtonStyle()) // ボタン枠内をタップ領域にする
                .padding(.top, 16)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 49)
        .background(ColorCodes.primary.color())
    }
}
