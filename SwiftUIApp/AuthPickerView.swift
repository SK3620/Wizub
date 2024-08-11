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
        GeometryReader { geometry in
            VStack {
                AuthSegmentedControl(
                    selectedSegment: $authViewModel.segmentType
                )
                .padding(.top, geometry.size.height * 0.1)

                AuthView(authViewModel: authViewModel, segmentType: authViewModel.segmentType)
            }
        }
    }
}

#Preview {
    return AuthPickerView(authViewModel: AuthViewModel())
}
