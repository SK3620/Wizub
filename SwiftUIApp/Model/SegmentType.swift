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
    
    // サインインのセグメント
    case signInSegment
    // サインアップのセグメント
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
        return ColorCodes.buttonBackground.color()
    }
}
