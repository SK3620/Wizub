//
//  SegmentType.swift
//  SwiftUIApp
//
//  Created by 鈴木 健太 on 2024/08/11.
//

import SwiftUI

protocol SegmentTypeProtocol: CaseIterable, Identifiable<SegmentType>, Equatable {
    var title: String { get }
    var tintColor: Color { get }
}

enum SegmentType: SegmentTypeProtocol {
    
    // ログインのセグメント
    case signInSegment
    // アカウント登録のセグメント
    case signUpSegment
    
    // 自身のインスタンスを識別子とする
    var id: Self {
        return self
    }

    var title: String {
        switch self {
        case .signInSegment:
            return "Sign In"
        case .signUpSegment:
            return "Sign Up"
        }
    }
    
    var tintColor: Color {
        return Color(red: 0.3, green: 0.0, blue: 0.5)
    }
}
