//
//  ColorCodes.swift
//  SwiftUIApp
//
//  Created by 鈴木 健太 on 2024/08/11.
//

import SwiftUI

enum ColorCodes {
    case primary
    case primary2
    case primaryBlack
    case primaryGray
    case primaryGray2
    case primaryLightGray
    case success
    case failure
    case background
    case buttonBackground
}

extension ColorCodes {
    
    func color() -> Color {
        switch self {
        case .primary:
            return Color(red: 0.3, green: 0.0, blue: 0.5)
        case .primary2:
            return Color(red: 0.95, green: 0.95, blue: 1.0)
        case .primaryBlack:
            return Color.black
        case .primaryGray:
            return Color.gray
        case .primaryGray2:
            return Color(red: 0.45, green: 0.45, blue: 0.45)
        case .primaryLightGray:
            return Color(red: 0.9, green: 0.9, blue: 0.9)
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
