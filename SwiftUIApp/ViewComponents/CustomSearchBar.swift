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

    @Binding var text: String
    @State private var isEditing = false

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
                .introspect(.textField, on: .iOS(.v13, .v14, .v15, .v16, .v17, .v18), customize: { textField in
                    textField.returnKeyType = .search
                    textField.attributedPlaceholder = NSAttributedString(
                        string: "Search",
                        attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray] // 任意の色を指定
                    )
                })
                .padding(.top, 10)
                .padding(.bottom, 10)
                .onTapGesture {
                    self.isEditing = true
                }
              
                if isEditing {
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

    public func onSearchButtonClick(action: () -> Void) -> some View {
        action()
        return self
    }
}
