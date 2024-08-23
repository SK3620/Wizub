//
//  StudyTabBarView.swift
//  SwiftUIApp
//
//  Created by 鈴木 健太 on 2024/08/22.
//

import SwiftUI

struct StudyTabBarView: View {
    
    var rewindAction: () -> Void
    var pauseAction: () -> Void
    var fastForwardAction: () -> Void
    var isPaused: Bool
    
    var body: some View {
        HStack(spacing: 24) {
            
            Spacer()
            
            Button {
                
            } label: {
                Image(systemName: "ellipsis.circle")
                    .font(.system(size: 24))
            }
            
            Spacer()
            
            Button(action: {
                rewindAction()
            }) {
                Image(systemName: "gobackward.5")
                    .font(.system(size: 24))
            }
            
            Button(action: {
               pauseAction()
            }) {
                Image(systemName: isPaused ? "play.circle.fill" : "pause.circle.fill")
                    .font(.system(size: 35))
            }

            Button(action: {
                fastForwardAction()
            }) {
                Image(systemName: "goforward.5")
                    .font(.system(size: 24))
            }
            
            Spacer()
            
            Button {
                
            } label: {
                Image(systemName: "ellipsis.circle")
                    .font(.system(size: 24))
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .frame(height: 49)
        .background(Color(UIColor.lightGray))
    }
}

#Preview {
    StudyTabBarView(
        rewindAction: { print("Rewind") },
        pauseAction: { print("Pause") },
        fastForwardAction: { print("Fast-forward")},
        isPaused: false
    )
}
