//
//  AuthPickerView.swift
//  SwiftUIApp
//
//  Created by 鈴木 健太 on 2024/08/10.
//

import SwiftUI

struct AuthPickerView: View {
   
    @ObservedObject private var authViewModel: AuthViewModel
    
    init(authViewModel: AuthViewModel) {
        self.authViewModel = authViewModel
    }

    var body: some View {
        VStack {
            AuthSegmentedControl(
                selectedSegment: $authViewModel.segmentType
                )
            .padding()
            
            switch (authViewModel.segmentType) {
            case .loginSegment:
                Text("Login")
            case .registerSegment:
                Text("Register")
            }
        }
    }
}

#Preview {
    return AuthPickerView(authViewModel: AuthViewModel())
}
