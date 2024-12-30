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
    
    // TextEditorのフォーカス状態の管理
    @FocusState private var isFocusedField: Bool
    
    // アプリサポート画面表示状態
    @State var showAppSupport: Bool = false
    
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
                    AuthView(authViewModel: authViewModel, focusedState: $isFocusedField)
                        .shadow(color: .gray.opacity(0.5), radius: 2)
                    
                    Spacer()
                }
                .fullScreenCover(isPresented: $authViewModel.showTermsAndConditions, content: {
                    TermsOfServiceView(url: MyAppSettings.termsAndConditionsUrl, isPresented: $authViewModel.showTermsAndConditions)
                })
                .onChange(of: authViewModel.successStatus?.shouldNavigate ?? false, initial: false) { oldValue, newValue in
                    // 非同期処理成功後、Home画面へ遷移
                    guard newValue else { return }
                    navigationPathEnv.path.append(.home)
                }
                
                // 非同期処理中はローディング
                if authViewModel.isLoading {
                    CommonProgressView()
                }
                
                // アカウント削除成功ダイアログ表示
                if let successStatus = authViewModel.successStatus {
                    CommonSuccessMsgView(
                        text: successStatus.toSuccessMsg,
                        isShow: successStatus == .accountDeleted
                    )
                }
                
                // アプリサポート画面表示
                if showAppSupport {
                    AppSupportView(isPresented: $showAppSupport)
                }
            }
            .alert(item: $authViewModel.alertType, content: { alertType in
                switch alertType {
                    // アカウント削除確認用アラート
                case .deleteAccount:
                    Alert(title: Text("アカウント削除"), message: Text("本当にアカウントを削除してもよろしいですか？"), primaryButton: .destructive(Text("削除"), action: {
                        authViewModel.apply(taps: .deleteAccount)
                    }), secondaryButton: .cancel(Text("キャンセル")))
                    // エラー用アラート
                case .error:
                    Alert(title: Text("エラー"), message: Text(authViewModel.myAppErrorMsg), dismissButton: .default(Text("OK")))
                }
            })
            .navigationDestination(for: NavigationPath.self, destination: { appended in
                appended.Destination()
                //                    .navigationTitle(appended.toString) HomeViewでタイトル表示
                    .navigationBarTitleDisplayMode(.inline)
            })
            .toolbar {
                if !isFocusedField {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            showAppSupport = true
                        } label: {
                            Image(systemName: "doc.questionmark")
                                .foregroundColor(.gray)
                        }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            authViewModel.apply(taps: .trialUse)
                        } label: {
                            Text("お試し")
                                .foregroundColor(ColorCodes.primary.color())
                                .fontWeight(.medium)
                        }
                    }
                }
            }
        }
        .accentColor(.black) // navigationBarのbackボタンの色
    }
}

#Preview {
    return AuthPickerView()
}
