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
    case successGreen
    case successGreen2
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
        case .successGreen:
            return Color(red: 0.1, green: 0.45, blue: 0.1)
        case .successGreen2:
            return Color(red: 0.92, green: 0.98, blue: 0.94)
        case .failure:
            return Color.red
        case .background:
            return Color.white
        case .buttonBackground:
            return Color(red: 0.3, green: 0.0, blue: 0.5)
        }
    }
}
