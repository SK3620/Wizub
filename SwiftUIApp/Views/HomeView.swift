//
//  HomeView.swift
//  SwiftUIApp
//
//  Created by 鈴木 健太 on 2024/08/19.
//

import SwiftUI
import KRProgressHUD
import UIKit

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
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showSignedInUsername()
                } label: {
                    Image(systemName: "person")
                        .foregroundColor(.gray)
                }
            }
        }
        .navigationTitle(currentTab.tabTitle())
        .ignoresSafeArea(.keyboard) // SerachBarへのフォーカス時、BottomTabBarも持ち上げない
    }
    
    private func showSignedInUsername() {
        KRProgressHUD.set(font: UIFont(name: "Helvetica Neue", size: 18)!)
        KRProgressHUD.set(duration: 2.5)
        KRProgressHUD.set(style: .custom(
            background: ColorCodes.primary2.uiColor(),
            text: ColorCodes.primary.uiColor(),
            icon: nil
        ))
        KRProgressHUD.showMessage("ユーザー名\n\n\(KeyChainManager().loadCredentials(service: .username))")
    }
}

#Preview {
    HomeView()
}
