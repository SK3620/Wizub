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
                ColorCodes.primary2.color()
                    .ignoresSafeArea()
                
                VStack {
                    // SingUp/SignInセグメント
                    CommonSegmentedControl(
                        selectedSegment: $authViewModel.authSegmentType,
                        configuration: .init(
                            height: 70,
                            cornerRadius: 35,
                            horizontalPadding: 16,
                            font: .title2
                        )
                    )
                    .shadow(color: .gray.opacity(0.7), radius: 1)
                    .padding(.top, 70)
                    
                    Spacer()
                    
                    // SingUp/SignIn画面
                    AuthView(authViewModel: authViewModel)
                        .shadow(color: .gray.opacity(0.5), radius: 2)
                    
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
                Alert(title: Text("エラー"), message: Text(authViewModel.httpErrorMsg), dismissButton: .default(Text("OK")))
            }
            .navigationDestination(for: NavigationPath.self, destination: { appended in
                appended.Destination()
//                    .navigationTitle(appended.toString) HomeViewでタイトル表示
                    .navigationBarTitleDisplayMode(.inline)
            })
        }
        .accentColor(.black) // navigationBarのbackボタンの色
    }
}

#Preview {
    return AuthPickerView()
}
