//
//  TranslateView.swift
//  SwiftUIApp
//
//  Created by 鈴木 健太 on 2024/08/29.
//

import SwiftUI

enum TranslateSegmentType: CommonSegmentTypeProtocol {
    
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

struct TranslateView: View {
    
    @State var segmentType: TranslateSegmentType = .selected
    // 選択された数字
    @State var selectedSectionNum: Int = 0
    
    // 選択した字幕
    var selectedChunkedSubtitles: [[SubtitleModel.SubtitleDetailModel]]
    // 全ての字幕
    var allChunkedSubtitles: [[SubtitleModel.SubtitleDetailModel]]
    // 翻訳
    var translateSubtitles: ([SubtitleModel.SubtitleDetailModel]) -> Void
    
    private var chunkedSubtitles: [[SubtitleModel.SubtitleDetailModel]] {
        switch segmentType {
        case .selected:
            return selectedChunkedSubtitles
        case .all:
            return allChunkedSubtitles
        }
    }
    
    init(
         selectedChunkedSubtitles: [[SubtitleModel.SubtitleDetailModel]],
         allChunkedSubtitles: [[SubtitleModel.SubtitleDetailModel]],
         translateSubtitles: @escaping ([SubtitleModel.SubtitleDetailModel]) -> Void
    ) {
        self.selectedChunkedSubtitles = selectedChunkedSubtitles
        self.allChunkedSubtitles = allChunkedSubtitles
        self.translateSubtitles = translateSubtitles
    }
    
    var body: some View {
        VStack(spacing: 16) {
            
            Text("翻訳リスト")
                .font(.title2)
                .fontWeight(.medium)
            
            // 選択中の字幕リスト/全ての字幕リスト表示切り替え
            CommonSegmentedControl(selectedSegment: $segmentType)
                .shadow(color: .gray, radius: 1)
            
            // 字幕要素数が2以上ならば、セクションを表示する
            if chunkedSubtitles.count > 1 {
                // 翻訳する字幕数を分割するセクション
                ChunkedSubtitleSegmentControl(sectionNumCount: chunkedSubtitles.count, selectedSectionNum: $selectedSectionNum)
                    .padding(.top, -8) // 上のUIパーツとの間隔を狭める
            }
            
            // 字幕をリスト表示
            SubtitleList(subtitles: chunkedSubtitles.isEmpty ? [] : chunkedSubtitles[selectedSectionNum] )
            
            // 翻訳ボタン
            TranslateButton(
                action: { translateSubtitles(chunkedSubtitles[selectedSectionNum])},
                title: "ChatGPT 翻訳",
                disableButton: chunkedSubtitles.isEmpty
            )
        }
        .padding()
    }
}

// 翻訳する字幕数を分割するセクション
struct ChunkedSubtitleSegmentControl: View {
    // 分割された字幕要素数の数
    var sectionNumCount: Int
    // 選択された数字
    @Binding var selectedSectionNum: Int
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(0..<sectionNumCount, id: \.self) { number in
                    Button(action: {
                        selectedSectionNum = number
                    }) {
                        Text("\(number + 1)")
                            .font(.title3)
                            .fontWeight(.medium)
                            .frame(width: 40, height: 25)
                            .background(selectedSectionNum == number ? ColorCodes.primary.color() : ColorCodes.primaryLightGray.color())
                            .foregroundColor(selectedSectionNum == number ? Color.white : .black)
                            .cornerRadius(25)
                    }
                    .buttonStyle(PlainButtonStyle()) // ボタン枠内をタップ領域にする
                }
            }
            .padding(.horizontal)
        }
        .frame(height: 40)
        .background(.white)
        .cornerRadius(30)
        .shadow(color: .gray, radius: 1)
        .padding(.horizontal, 32)
    }
}

// 字幕リスト
struct SubtitleList: View {
    var subtitles: [SubtitleModel.SubtitleDetailModel]
    
    var body: some View {
        ZStack {
            List(subtitles) {
                Text($0.enSubtitle)
                    .padding([.vertical, .horizontal], 16)
                // 以下は区切り線を端から端まで伸ばす
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .listRowSeparator(.hidden)
                    .listRowInsets(.init(top:0,leading:0,bottom:0,trailing:0))
                    .overlay(
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(.gray.opacity(0.3)),
                        alignment: .bottom
                    )
            }
            .listStyle(.inset)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.gray, lineWidth: 0)
            )
            .shadow(color: .gray, radius: 1)
            
            if subtitles.isEmpty {
                VStack {
                    Spacer()
                    Text("選択中の字幕がありません")
                        .font(.headline)
                        .foregroundColor(ColorCodes.primaryGray.color())
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
}


// 翻訳ボタン
struct TranslateButton: View {
    var action: () -> Void
    var title: String
    var disableButton: Bool
    
    var body: some View {
        VStack(spacing: 4) {
            Button {
                action()
            } label: {
                HStack(spacing: 16) {
                    Text(title)
                        .font(.headline)
                }
                .foregroundColor(.white)
                .padding(.horizontal, 40)
                .padding(.vertical, 16)
                .background(
                    Capsule()
                        .fill(!disableButton ? ColorCodes.buttonBackground.color() : ColorCodes.buttonBackground.color().opacity(0.3))
                )
            }
            .disabled(disableButton)
        }
    }
}
