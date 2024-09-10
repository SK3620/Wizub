//
//  CustomSearchBar.swift
//  SwiftUIApp
//
//  Created by 鈴木 健太 on 2024/08/19.
//

import SwiftUI
import UIKit
import SwiftUIIntrospect

struct CustomSearchBar: View {
    // TextFieldのフォーカス状態の管理
    @FocusState private var isFocused: Bool
    // 入力値
    @Binding var text: String

    var onSearchButtonClick: () -> Void

    var body: some View {
        ZStack(alignment: .leading) {
            HStack {

                Image(systemName: "magnifyingglass")
                    .foregroundColor(Color(.darkGray))
                    .padding(.leading, 10)

                TextField("Search", text: $text,
                          onCommit: {
                    guard !text.isEmpty else { return }
                            self.onSearchButtonClick()
                          }
                )
                .focused($isFocused) // フォーカス状態を管理
                .toolbar {
                    ToolbarItemGroup(placement: .keyboard) {
                        Spacer()
                        // 閉じるボタン
                        Button {
                            // フォーカスを外してキーボードを閉じる
                            isFocused = false
                        } label: {
                            Text("閉じる")
                                .fontWeight(.medium)
                        }
                    }
                }
                .introspect(.textField, on: .iOS(.v13, .v14, .v15, .v16, .v17, .v18), customize: { textField in
                    // SwiftUIIntrospectでカスタマイズ
                    textField.returnKeyType = .search
                    // 背景色変更
                    textField.attributedPlaceholder = NSAttributedString(
                        string: "Search",
                        attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray]
                    )
                })
                .padding(.vertical, 10)
                .onTapGesture {
                    isFocused = true
                }
              
                if isFocused {
                    Button(action: {
                        self.text = ""
                    }, label: {
                        Image(systemName: "multiply.circle.fill")
                            .foregroundColor(.gray)
                            .offset(x: -10)
                    })
                }

            }
        }
        .background(Color(.gray.withAlphaComponent(0.25)))
        .cornerRadius(16)
    }
}
