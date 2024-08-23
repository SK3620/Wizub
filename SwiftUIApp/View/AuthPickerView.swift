//
//  AuthPickerView.swift
//  SwiftUIApp
//
//  Created by 鈴木 健太 on 2024/08/10.
//

import SwiftUI

struct AuthPickerView: View {
    
    // ナビゲーションパスの状態管理用クラス
    @EnvironmentObject var navigationPathEnv: NavigationPathEnvironment

    @StateObject private var authViewModel: AuthViewModel = AuthViewModel(apiService: APIService())
    
    var body: some View {
        NavigationStack(path: $navigationPathEnv.path) {
            ZStack {
                // 背景色
                Color.gray.opacity(0.1).ignoresSafeArea()
                
                VStack {
                    // SingUp/SignInセグメント
                    AuthSegmentedControl(
                        selectedSegment: $authViewModel.segmentType
                    )
                    .padding(.top, 70)
                    
                    Spacer()
                    
                    // SingUp/SignIn画面
                    AuthView(authViewModel: authViewModel, segmentType: authViewModel.segmentType)
                    
                    Spacer()
                }
                // SignUp/SignIn非同期処理状況を監視
                .onChange(of: authViewModel.statusViewModel.shouldTransition, initial: false) { oldValue, newValue in
                    // 非同期処理成功後、Home画面へ遷移
                    guard newValue else { return }
//                    path.append(.home)
                    navigationPathEnv.path.append(.home)
                    authViewModel.statusViewModel.shouldTransition = false
                }
                
                // 非同期処理中はローディング
                if authViewModel.statusViewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                        .scaleEffect(2.5)
                        .padding()
                }
            }
            .alert(isPresented: $authViewModel.statusViewModel.showErrorMessage) {
                Alert(title: Text("Error"), message: Text(authViewModel.statusViewModel.alertErrorMessage), dismissButton: .default(Text("OK")))
            }
            .navigationDestination(for: NavigationPath.self, destination: { appended in
                appended.Destination()
                    .navigationTitle(appended.toString)
                    .navigationBarTitleDisplayMode(.inline)
            })
        }
    }
}

#Preview {
    return AuthPickerView()
}