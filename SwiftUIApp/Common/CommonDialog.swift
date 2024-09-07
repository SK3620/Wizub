//
//  CommonDialog.swift
//  SwiftUIApp
//
//  Created by 鈴木 健太 on 2024/09/06.
//

import SwiftUI

struct CommonDialog: View {
    struct Content {
        let title: String
        let message: String
        var onConfirm: (() -> Void)?
        var onCancel: (() -> Void)?
    }
    var content: Content
    var onDismiss: (() -> Void)
    
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                Color.black.opacity(0.7)
                    .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    Text(content.title).font(.title)
                    Text(content.message)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    HStack {
                        Button {
                            content.onCancel?()
                            onDismiss()
                        } label: {
                            Text("Cancel")
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                        Button {
                            content.onConfirm?()
                            onDismiss()
                        } label: {
                            Text("OK")
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                    }
                    .frame(height: 56)
                }
                .padding([.top, .horizontal])
                .frame(width: proxy.size.width * 0.8, height: proxy.size.height * 0.7)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 16.0))
            }
        }
    }
}
