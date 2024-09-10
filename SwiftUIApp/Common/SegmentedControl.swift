//
//  SegmentedControl.swift
//  SwiftUIApp
//
//  Created by 鈴木 健太 on 2024/09/10.
//

import SwiftUI

// CaseIterable: enumが持つすべてのケースを.allCasesを使用し、自動的に配列として提供できる
protocol CommonSegmentTypeProtocol: CaseIterable, Identifiable, Equatable {
    var title: String { get }
    var tintColor: Color { get }
}

// SegmentType.AllCases は[SegmentType] 型である
struct CommonSegmentedControl<SegmentType: CommonSegmentTypeProtocol>: View where SegmentType.AllCases == [SegmentType] {
    
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

    //SegmentTypeをEquatableに準拠させ、演算子の使用をサポートさせ、比較可能にさせる。
    private func isSelected(segment: SegmentType) -> Bool {
        selectedSegment == segment
    }
}
