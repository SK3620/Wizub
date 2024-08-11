//
//  SegmentType.swift
//  SwiftUIApp
//
//  Created by 鈴木 健太 on 2024/08/11.
//

import SwiftUI

protocol SegmentTypeProtocol: CaseIterable, Identifiable<SegmentType>, Equatable {
    var title: String { get }
    var tintColor: Color? { get }
}

extension SegmentTypeProtocol {
    var tintColor: Color? { nil }
}

enum SegmentType: SegmentTypeProtocol {
    
    // ログインのセグメント
    case loginSegment
    // アカウント登録のセグメント
    case registerSegment
    
    // 自身のインスタンスを識別子とする
    var id: Self {
        return self
    }

    var title: String {
        switch self {
        case .loginSegment:
            return "Login"
        case .registerSegment:
            return "Register"
        }
    }
    
    var tintColor: Color? {
        switch self {
        case .loginSegment:
            return .red.opacity(0.75)
        case .registerSegment:
            return .green.opacity(0.75)
        }
    }
}
