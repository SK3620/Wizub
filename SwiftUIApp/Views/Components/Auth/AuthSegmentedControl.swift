//
//  AuthSegmentedControl.swift
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

struct AuthSegmentedControl<SegmentType: SegmentTypeProtocol>: View where SegmentType.AllCases == [SegmentType] {
    
    struct Configuration {
        var selectedForegroundColor: Color = .white
        var selectedBackgroundColor: Color = .black.opacity(0.75)
        var foregroundColor: Color = .black
        var backgroundColor: Color = .gray.opacity(0.25)
    }

    @Binding var selectedSegment: SegmentType
    var configuration: Configuration = .init()

    var body: some View {
        HStack(spacing: 0) {
            ForEach(SegmentType.allCases) { segment in
                ZStack {
                    Rectangle()
                        .fill(.white)
                    
                    Button(action: {
                        withAnimation(.default) {
                            selectedSegment = segment
                        }
                    }, label: {
                        Text(segment.title)
                            .font(.title2)
                            .foregroundStyle(isSelected(segment: segment) ? configuration.selectedForegroundColor : configuration.foregroundColor)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .contentShape(Rectangle())
                            .background {
                                if isSelected(segment: segment) {
                                    Rectangle()
                                        .fill(segment.tintColor)
                                        .clipShape(RoundedRectangle(cornerRadius: 35))
                                        .padding(8)
                                }
                            }
                    })
                    .buttonStyle(.plain)
                }
            }
        }
        .frame(height: 70)
        .clipShape(RoundedRectangle(cornerRadius: 35))
        .shadow(color: .gray.opacity(0.7), radius: 5)
        .padding()
    }

    private func isSelected(segment: SegmentType) -> Bool {
        selectedSegment == segment
    }
}
