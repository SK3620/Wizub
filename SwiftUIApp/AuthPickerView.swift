//
//  AuthPickerView.swift
//  SwiftUIApp
//
//  Created by 鈴木 健太 on 2024/08/10.
//

import SwiftUI

struct AuthPickerView: View {
    
    @StateObject private var authViewModel: AuthViewModel = AuthViewModel()
    
    var body: some View {
        ZStack {
            // 背景色
            Color.gray.opacity(0.1).ignoresSafeArea()
            
            VStack {
                AuthSegmentedControl(
                    selectedSegment: $authViewModel.segmentType
                )
                .padding(.top, 70)
                
                Spacer()
                
                AuthView(authViewModel: authViewModel, segmentType: authViewModel.segmentType)
                
                Spacer()
            }
        }
    }
}

#Preview {
    return AuthPickerView()
}
