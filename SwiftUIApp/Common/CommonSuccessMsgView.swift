//
//  CommonSuccessMsgView.swift
//  SwiftUIApp
//
//  Created by 鈴木 健太 on 2024/09/27.
//

import SwiftUI

struct CommonSuccessMsgView: View {
    var text: String = ""
    @State var isShow: Bool = true
    
    var body: some View {
        if isShow {
            VStack {
                Spacer()
                HStack(spacing: 8) {
                   
                    Image(systemName: "checkmark")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(ColorCodes.successGreen.color())
                    
                    Text(text)
                        .font(.headline)
                        .foregroundColor(ColorCodes.successGreen.color())
                }
                .padding()
                .background(ColorCodes.successGreen2.color())
                .cornerRadius(15)
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(ColorCodes.successGreen.color().opacity(0.5), lineWidth: 1) // 枠線の色と太さを指定
                )
                .animation(.easeInOut, value: isShow)

                Spacer()
            }
            .onAppear {
                // 3秒後に非表示にする
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    withAnimation {
                        isShow = false
                    }
                }
            }
        }
    }
}

struct CommonSuccessMsgView_Previews: PreviewProvider {
    static var previews: some View {
        CommonSuccessMsgView()
    }
}


#Preview {
    CommonSuccessMsgView()
}
