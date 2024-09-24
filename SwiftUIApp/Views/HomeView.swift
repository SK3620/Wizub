//
//  HomeView.swift
//  SwiftUIApp
//
//  Created by 鈴木 健太 on 2024/08/19.
//

import SwiftUI

struct HomeView: View {
    
    @State var currentTab: Tab = .videoList
    
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
        }
        .navigationTitle(currentTab.tabTitle())
        .ignoresSafeArea(.keyboard) // SerachBarへのフォーカス時、BottomTabBarも持ち上げない
    }
}

#Preview {
    HomeView()
}
