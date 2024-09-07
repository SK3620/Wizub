//
//  AuthTextField.swift
//  SwiftUIApp
//
//  Created by 鈴木 健太 on 2024/09/05.
//

import SwiftUI

struct AuthTextField: View {
    
    var title: String
    @Binding var textValue: String
    var errorValue: String
    var isSecured: Bool = false
    var keyboardType: UIKeyboardType = .default
    
    @State private var isEditing: Bool = false
    
    var body: some View {
        VStack {
            ZStack(alignment: .leading) {
                Text(title)
                    .font(.title2)
                    .foregroundColor(.gray)
                    .background(Color.white)
                    .padding(.horizontal, 0)
                // floatingtextFieldLabelの実装
                    .scaleEffect(isEditing || !textValue.isEmpty ? 0.8 : 1.0, anchor: .leading)
                    .offset(y: isEditing || !textValue.isEmpty ? -35 : 0)
                    .animation(.easeInOut(duration: 0.2), value: isEditing || !textValue.isEmpty)
                
                VStack {
                    if isSecured {
                        SecureField("", text: $textValue, onCommit: {
                            // エンター押下時
                            self.isEditing = false
                        })
                            .font(.title2)
                            .padding()
                            .keyboardType(keyboardType)
                            .onTapGesture {
                                // フィールド押下時
                                self.isEditing = true
                            }
                    } else {
                        TextField("", text: $textValue, onEditingChanged: { editing in
                            self.isEditing = editing
                        })
                        .font(.title2)
                        .padding()
                        .keyboardType(keyboardType)
                    }
                    Divider()
                        .padding(.top, -17)
                }
            }
            
            Text(errorValue)
                .fontWeight(.light)
                .foregroundStyle(ColorCodes.failure.color())
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .trailing)
                .padding(EdgeInsets(top: -24, leading: 0, bottom: 24, trailing: 0))
        }
    }
}
