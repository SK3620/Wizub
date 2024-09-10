//
//  CustomDialog.swift
//  SwiftUIApp
//
//  Created by 鈴木 健太 on 2024/08/30.
//

import SwiftUI

import SwiftUI

struct EditDialogView: View {
    // 編集中の英語字幕
    @State private var editedEnSubtitle: String
    // 編集中の日本語字幕
    @State private var editedJaSubtitle: String
    
    @Binding var isPresented: Bool
    
    // TextEditorのフォーカス状態の管理（共通管理）
    @FocusState private var isFocused: Bool
    
    // OKボタン押下時
    var onConfirm: (String, String) -> Void
    
    init(editedEnSubtitle: String?, editedJaSubtitle: String?, isPresented: Binding<Bool>, onConfirm: @escaping (String, String) -> Void) {
        self.editedEnSubtitle = editedEnSubtitle ?? ""
        self.editedJaSubtitle = editedJaSubtitle ?? ""
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
                        
                        CustomTextEditor(text: $editedEnSubtitle, title: "英語字幕", isFocused: $isFocused)
                        CustomTextEditor(text: $editedJaSubtitle, title: "日本語字幕", isFocused: $isFocused)
                        
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
                                onConfirm(editedEnSubtitle, editedJaSubtitle)
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
                    // キーボードに閉じるボタン配置
                    .toolbar {
                        ToolbarItemGroup(placement: .keyboard) {
                            Spacer()
                            Button {
                                // フォーカスを外してキーボードを閉じる
                                isFocused = false
                            } label: {
                                Text("閉じる")
                                    .fontWeight(.medium)
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

struct CustomTextEditor: View {
    @Binding var text: String
    let title: String
    
    // 親ビューで管理されるフォーカス状態をバインド 現在のフォーカス状態の読み書き可能
    @FocusState.Binding var isFocused: Bool
    
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
                .focused($isFocused)
        }
    }
}
