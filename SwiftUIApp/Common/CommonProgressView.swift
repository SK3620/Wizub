//
//  CustomProgressView.swift
//  SwiftUIApp
//
//  Created by 鈴木 健太 on 2024/08/26.
//

import SwiftUI

struct CommonProgressView: View {
    
    var text: String = ""
    
    var body: some View {
        VStack {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .purple))
                .scaleEffect(2.5)
                .padding()
            
            Text(text)
        }
    }
}

#Preview {
    CommonProgressView()
}
