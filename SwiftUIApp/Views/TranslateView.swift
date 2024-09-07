//
//  TranslateView.swift
//  SwiftUIApp
//
//  Created by 鈴木 健太 on 2024/08/29.
//

import SwiftUI

struct TranslateView: View {
    
    @ObservedObject var studyViewModel: StudyViewModel
    
    @State var segmentType: TranslateSegmentType = .selected
    
    init(studyViewModel: StudyViewModel) {
        self.studyViewModel = studyViewModel
        
        // TextEditorのTextのpadding設定
        UITextView.appearance().textContainerInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    }
    
    var body: some View {
        VStack(spacing: 16) {
            
            Text("翻訳リスト")
                .font(.title2)
                .fontWeight(.medium)
            
            TranslateSegmentedControl(selectedSegment: $segmentType)
            
            if segmentType == .selected {
                // 選択中の字幕
                List {
                    ForEach(studyViewModel.translatedTranscripts) {
                        Text($0.enSubtitle)
                    }
                }
                .listStyle(.inset)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.gray, lineWidth: 0)
                )
            } else {
                // 全ての字幕
                List {
                    ForEach(studyViewModel.transcriptDetail) {
                        Text($0.enSubtitle)
                    }
                }
                .listStyle(.inset)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.gray, lineWidth: 0)
                )
            }
            
            // 翻訳ボタン
            Button(action: {
                // ローディングアイコン表示開始
                studyViewModel.statusViewModel = StatusViewModel(isLoading: true)
                if segmentType == .selected {
                    // 選択中の字幕の翻訳
                    studyViewModel.translate(translatedTranscript2: studyViewModel.translatedTranscripts)
                } else {
                    // 全ての字幕の翻訳
                    studyViewModel.translate(translatedTranscript2: studyViewModel.transcriptDetail)
                }
            }) {
                HStack(spacing: 16) {
                    Text("ChatGPT 翻訳")
                        .font(.headline)
                }
                .foregroundColor(.white)
                .padding(.horizontal, 40)
                .padding(.vertical, 16)
                .background(
                    Capsule()
                        .fill(ColorCodes.primary.color())
                )
            }
        }
        .disabled(studyViewModel.statusViewModel.isLoading)
        .padding()
        .onAppear {
            // idが低い順にsort
            studyViewModel.translatedTranscripts.sort(by: { $0.id < $1.id })
        }
    }
}

#Preview {
    TranslateView(studyViewModel: StudyViewModel(apiService: APIService(), youTubePlayer: "fafaw"))
}
