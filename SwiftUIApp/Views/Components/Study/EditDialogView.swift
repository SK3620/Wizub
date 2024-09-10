import SwiftUI

enum EditSubtitleSegmentType: CommonSegmentTypeProtocol {
    case memo
    case subtitles

    var id: Self { self }

    var title: String {
        switch self {
        case .memo:
            return "メモ"
        case .subtitles:
            return "字幕"
        }
    }
    
    var tintColor: Color {
        return ColorCodes.buttonBackground.color()
    }
}

struct EditDialogView: View {
    // フォーカスが当たるTextEditorを判断する
    enum Editor: Hashable {
        case enSubtitle
        case jaSubtitle
        case memo
    }
    // 字幕/学習メモ セグメント選択
    @State var segmentType: EditSubtitleSegmentType = .memo
    // 編集中の英語字幕
    @State private var editedEnSubtitle: String
    // 編集中の日本語字幕
    @State private var editedJaSubtitle: String
    // 学習メモ
    @State private var editedMemo: String
    
    @Binding var isPresented: Bool
    
    // TextEditorのフォーカス状態の管理
    @FocusState private var focusedEditor: Editor?
    
    // OKボタン押下時
    var onConfirm: (String, String, String) -> Void
    
    init(editedEnSubtitle: String?, editedJaSubtitle: String?, editedMemo: String?, isPresented: Binding<Bool>, onConfirm: @escaping (String, String, String) -> Void) {
        self.editedEnSubtitle = editedEnSubtitle ?? ""
        self.editedJaSubtitle = editedJaSubtitle ?? ""
        self.editedMemo = editedMemo ?? ""
        self._isPresented = isPresented
        self.onConfirm = onConfirm
        
        // TextEditorのTextのpadding設定
        UITextView.appearance().textContainerInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    }
    
    var body: some View {
        if isPresented {
            ZStack {
                Color.black.opacity(0.7)
                    .ignoresSafeArea()
                
                ZStack {
                    VStack(spacing: 16) {
                        Text("編集")
                            .font(.title2)
                            .fontWeight(.medium)
                        
                        // 字幕/学習メモ セグメント選択
                        CommonSegmentedControl(selectedSegment: $segmentType)
                        
                        if segmentType == .memo {
                            // 学習メモセグメント
                            CustomTextEditor(text: $editedMemo, title: "学習メモ", focusedEditor: $focusedEditor, currentEditor: .memo)
                        } else {
                            // 字幕編集セグメント
                            CustomTextEditor(text: $editedEnSubtitle, title: "英語字幕", focusedEditor: $focusedEditor, currentEditor: .enSubtitle)
                            CustomTextEditor(text: $editedJaSubtitle, title: "日本語字幕", focusedEditor: $focusedEditor, currentEditor: .jaSubtitle)
                        }
                        
                        HStack {
                            Button {
                                isPresented = false
                            } label: {
                                Text("Cancel")
                                    .font(.title3)
                                    .fontWeight(.medium)
                                    .frame(maxWidth: .infinity)
                            }
                            
                            Button {
                                onConfirm(editedEnSubtitle, editedJaSubtitle, editedMemo)
                                isPresented = false
                            } label: {
                                Text("OK")
                                    .font(.title3)
                                    .fontWeight(.medium)
                                    .frame(maxWidth: .infinity)
                            }
                        }
                        .padding(.bottom, 16)
                    }
                    .padding([.top, .horizontal])
                    .frame(height: 500)
                    .background(Color(white: 0.9))
                    .clipShape(RoundedRectangle(cornerRadius: 16.0))
                    .toolbar {
                        ToolbarItemGroup(placement: .keyboard) {
                            Spacer()
                            Button {
                                // キーボードを閉じる
                                focusedEditor = nil
                            } label: {
                                Text("閉じる")
                                    .fontWeight(.medium)
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
            .ignoresSafeArea(isPresented ? .keyboard : .all)
        }
    }
}
