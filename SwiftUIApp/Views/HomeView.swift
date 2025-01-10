//
//  HomeView.swift
//  SwiftUIApp
//
//  Created by 鈴木 健太 on 2024/08/19.
//

import SwiftUI

struct HomeView: View {
    
    @State var currentTab: Tab = .videoList
    @State private var showUserInfo = false
    
    init() {
        // デフォルトのTabBarは使用しないので隠しておく
        UITabBar.appearance().isHidden = true
    }
    
    var body: some View {
        ZStack {
            VStack {
                TabView(selection: $currentTab) {
                    VideoListView()
                        .tag(Tab.videoList)
                    
                    SavedVideoListView()
                        .tag(Tab.practice)
                }
                
                CustomTabBar(currentTab: $currentTab)
            }
            
            // ユーザー情報を表示するカスタムビュー
            if showUserInfo {
                UserInfoHUDView()
                    .transition(.opacity)
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showSignedInUserInfo()
                } label: {
                    Image(systemName: "person")
                        .foregroundColor(.gray)
                }
            }
        }
        .navigationTitle(currentTab.tabTitle())
        .ignoresSafeArea(.keyboard) // SearchBarへのフォーカス時、BottomTabBarも持ち上げない
    }
    
    private func showSignedInUserInfo() {
        // ユーザー情報を表示する
        withAnimation {
            showUserInfo = true
        }
        // 3秒後に非表示
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            showUserInfo = false
        }
    }
}

#Preview {
    HomeView()
}
