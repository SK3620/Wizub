//
//  CustomTextEditor.swift
//  SwiftUIApp
//
//  Created by 鈴木 健太 on 2024/09/10.
//

import SwiftUI

struct CustomTextEditor: View {
    @Binding var text: String
    let title: String
    // 親ビューで管理されるフォーカス状態をバインド 現在のフォーカス状態の読み書き可能
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
                .shadow(color: .gray, radius: 1)
                .focused($focusedEditor, equals: currentEditor) // フォーカスの状態を管理
                .frame(maxHeight: .infinity) // 親要素の高さいっぱいに広げる
        }
    }
}
