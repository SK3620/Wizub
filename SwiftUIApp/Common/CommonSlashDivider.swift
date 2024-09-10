//
//  CommonHorizontalDivider.swift
//  SwiftUIApp
//
//  Created by 鈴木 健太 on 2024/09/10.
//

import SwiftUI

// Divider()を完全に透明にさせることができないため、CustomDividerを作成
struct CommonSlashDivider: View {
    
    let color: Color
    let width: CGFloat
    let height: CGFloat
    
    init(color: Color, width: CGFloat, height: CGFloat = 2.0) {
        self.color = color
        self.width = width
        self.height = height
    }
    
    var body: some View {
        color
            .frame(width: width, height: height)
            .rotationEffect(.degrees(10)) // 回転
    }
}
