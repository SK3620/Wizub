//
//  ColorCodes.swift
//  SwiftUIApp
//
//  Created by 鈴木 健太 on 2024/08/11.
//

import SwiftUI

enum ColorCodes {
    case primary
    case success
    case failure
    case background
    case buttonBackground
}

extension ColorCodes {
    
    func color() -> Color {
        switch self {
        case .primary:
            return Color.white
        case .success:
            return Color.green
        case .failure:
            return Color.red
        case .background:
            return Color.white
        case .buttonBackground:
            return Color(red: 0.3, green: 0.0, blue: 0.5)
        }
    }
}
