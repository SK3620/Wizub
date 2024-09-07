//
//  TranslateSegmentedControl.swift
//  SwiftUIApp
//
//  Created by 鈴木 健太 on 2024/08/31.
//

import SwiftUI

struct TranslateSegmentedControl<TranslateSegmentType: TranslateSegmentTypeProtocol>: View where TranslateSegmentType.AllCases == [TranslateSegmentType] {
    
    struct Configuration {
        var selectedForegroundColor: Color = .white
        var selectedBackgroundColor: Color = .black.opacity(0.75)
        var foregroundColor: Color = .black
        var backgroundColor: Color = .gray.opacity(0.25)
    }

    @Binding var selectedSegment: TranslateSegmentType
    var configuration: Configuration = .init()

    var body: some View {
        HStack(spacing: 0) {
            ForEach(TranslateSegmentType.allCases) { segment in
                ZStack {
                    Rectangle()
                        .fill(.white)
                    
                    Button(action: {
                        withAnimation(.default) {
                            selectedSegment = segment
                        }
                    }, label: {
                        Text(segment.title)
                            .font(.headline)
                            .foregroundStyle(isSelected(segment: segment) ? configuration.selectedForegroundColor : configuration.foregroundColor)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .contentShape(Rectangle())
                            .background {
                                if isSelected(segment: segment) {
                                    Rectangle()
                                        .fill(segment.tintColor)
                                        .clipShape(RoundedRectangle(cornerRadius: 30))
                                        .padding(8)
                                }
                            }
                    })
                    .buttonStyle(.plain)
                }
            }
        }
        .frame(height: 60)
        .clipShape(RoundedRectangle(cornerRadius: 30))
        .padding(.horizontal, 32)
    }

    private func isSelected(segment: TranslateSegmentType) -> Bool {
        selectedSegment == segment
    }
}

protocol TranslateSegmentTypeProtocol: CaseIterable, Identifiable<TranslateSegmentType>, Equatable {
    var title: String { get }
    var tintColor: Color { get }
}

enum TranslateSegmentType: TranslateSegmentTypeProtocol {
    
    // 選択された字幕の翻訳を行うセグメント
    case selected
    // 全ての字幕の翻訳を行うセグメント
    case all
    
    // 自身のインスタンスを識別子とする
    var id: Self {
        return self
    }

    var title: String {
        switch self {
        case .selected:
            return "選択中の字幕"
        case .all:
            return "全ての字幕"
        }
    }
    
    var tintColor: Color {
        return ColorCodes.buttonBackground.color()
    }
}
