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
                    AuthView(authViewModel: authViewModel)
                    
                    Spacer()
                }
                .onChange(of: authViewModel.isSuccess, initial: false) { oldValue, newValue in
                    // 非同期処理成功後、Home画面へ遷移
                    guard newValue else { return }
                    navigationPathEnv.path.append(.home)
                }
                
                 // 非同期処理中はローディング
                if authViewModel.isLoading {
                    CommonProgressView()
                }
            }
            .alert(isPresented: $authViewModel.isShowError) {
                Alert(title: Text("Error"), message: Text(authViewModel.httpErrorMsg), dismissButton: .default(Text("OK")))
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
