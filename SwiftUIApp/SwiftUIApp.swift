//
//  SwiftUIAppApp.swift
//  SwiftUIApp
//
//  Created by 鈴木 健太 on 2024/08/09.
//

import SwiftUI

@main
struct SwiftUIApp: App {
    
    let authViewModel = AuthViewModel()
    
    var body: some Scene {
        WindowGroup {
            AuthPickerView(authViewModel: authViewModel)
        }
    }
}
