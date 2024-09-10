import SwiftUI

struct EditDialogView: View {
    // フォーカスが当たるTextEditorを判断する
    enum Editor: Hashable {
        case enSubtitle
        case jaSubtitle
        case memo
    }
    
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
                        
                        // フォーカス制御付きのCustomTextEditor
                        CustomTextEditor(text: $editedEnSubtitle, title: "英語字幕", focusedEditor: $focusedEditor, currentEditor: .enSubtitle)
                        CustomTextEditor(text: $editedJaSubtitle, title: "日本語字幕", focusedEditor: $focusedEditor, currentEditor: .jaSubtitle)
                        CustomTextEditor(text: $editedMemo, title: "学習メモ", focusedEditor: $focusedEditor, currentEditor: .memo)

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
                    .frame(height: 600)
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

struct CustomTextEditor: View {
    @Binding var text: String
    let title: String
    @FocusState.Binding var focusedEditor: EditDialogView.Editor?
    let currentEditor: EditDialogView.Editor
    
    var body: some View {
        VStack {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 16)
            
            TextEditor(text: $text)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.gray, lineWidth: 0)
                )
                .focused($focusedEditor, equals: currentEditor) // フォーカスの状態を管理
                .frame(minHeight: 100, maxHeight: 150) // テキストエディタの高さを制限
        }
    }
}
