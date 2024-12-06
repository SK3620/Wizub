//
//  TermsAndConditionsView.swift
//  SwiftUIApp
//
//  Created by 鈴木 健太 on 2024/12/06.
//

import Foundation
import SwiftUI

struct TermsOfServiceView: View {
    let url: URL?
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationView {
            VStack {
                if let url = url {
                    WebView(url: url)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .edgesIgnoringSafeArea(.all)
                    
                    Button(action: {
                        isPresented = false
                    }) {
                        Text("同意する")
                            .frame(maxWidth: .infinity, maxHeight: 44)
                            .background(ColorCodes.primary.color())
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .padding([.leading, .trailing], 24)
                            .padding(.bottom, 16)
                    }
                } else {
                    Spacer()
                    Text("利用規約画面を表示できませんでした。\nもう一度お試しください。")
                        .foregroundColor(Color(white: 0.5))
                        .font(.headline)
                    Spacer()
                }
            }
            .navigationBarTitle("利用規約", displayMode: .inline)
            .toolbarBackground(Color.white, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }
}
