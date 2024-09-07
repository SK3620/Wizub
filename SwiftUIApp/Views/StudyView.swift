//
//  VideoPlayView.swift
//  SwiftUIApp
//
//  Created by 鈴木 健太 on 2024/08/21.
//

import SwiftUI
import YouTubePlayerKit
import Algorithms

protocol UpdateVideoInfoDelegate: AnyObject {
    func updateVideoInfo(videoInfo: CardView.VideoInfo)
}

struct StudyView: View {
    
    @StateObject var studyViewModel: StudyViewModel
    
    @State private var showMenuTabBar = false
    
    @State private var isShowSheet = false
    
    // 編集/翻訳アイコンを表示するかどうか
    @State private var showTranslateEditIcon = false
    
    // 編集画面を表示するかどうか
    @State private var showEditDialog = false
    
    // 編集するtranscript
    @State private var transcriptDetailModel: TranscriptModel.TranscriptDetailModel?
    
    // リスト内で押下された動画の情報
    private let videoInfo: CardView.VideoInfo
    
    // 現在の画面を閉じて前の画面に戻るための環境変数
    @Environment(\.dismiss) var dismiss
    
    // 保存完了後、親Viewで"videoInfo"を更新するように委譲
    weak var delegate: UpdateVideoInfoDelegate?
    
    init(videoInfo: CardView.VideoInfo) {
        self.videoInfo = videoInfo
        // '_' @StateObjectプロパティラッパーのバックアップストア（内部でデータを保持している場所）にアクセス
        _studyViewModel = StateObject(wrappedValue: StudyViewModel(apiService: APIService(), youTubePlayer: YouTubePlayer(stringLiteral: "https://youtube.com/watch?v=\(videoInfo.videoId)")))
    }
    
    var body: some View {
        ZStack {
            VStack {
                
                PlayVideoView(studyViewModel: studyViewModel)
                
                if studyViewModel.statusViewModel.isLoading {
                    // 中央に表示
                    VStack {
                        Spacer()
                        CommonProgressView()
                        Spacer()
                    }
                } else if studyViewModel.statusViewModel.showErrorMessage {
                    // エラーメッセージ表示
                    VStack {
                        Spacer()
                        Text(studyViewModel.statusViewModel.alertErrorMessage)
                            .foregroundColor(Color(white: 0.5))
                            .font(.headline)
                        Spacer()
                    }
                } else {
                    ScrollViewReader { proxy in
                        if studyViewModel.transcriptDisplayMode != .hideAll {
                            ZStack {
                                List {
                                    ForEach(Array(studyViewModel.transcriptDetail.enumerated()), id: \.offset){
                                        index, transcript in
                                        TranscriptListView(
                                            transcriptDetailModel: transcript,
                                            isHighlighted: studyViewModel.currentTranscriptIndex == index,
                                            displayMode: studyViewModel.transcriptDisplayMode,
                                            showTranslateEditIcon: showTranslateEditIcon,
                                            storeTranscript: {
                                                studyViewModel.translateButtonPressed.send(transcript)
                                            },
                                            removeTranscript: {
                                                studyViewModel.removeTranscriptButtonPressed.send(transcript)
                                            },
                                            editTranscript: { showEditDialog in
                                                // 編集する字幕
                                                self.transcriptDetailModel = transcript
                                                // 編集画面の表示フラグ
                                                self.showEditDialog = showEditDialog
                                            }
                                        )
                                        .onTapGesture {
                                            // ハイライトされるtranscriptを更新
                                            studyViewModel.currentTranscriptIndex = index
                                            studyViewModel.seekToTranscript(at: index)
                                        }
                                    }
                                }
                                .listStyle(.inset)
                                // transcriptのindexの変更を監視
                                .onChange(of: studyViewModel.currentTranscriptIndex, { oldIndex, newIndex in
                                    if let newIndex = newIndex {
                                        withAnimation {
                                            // 指定のtranscriptへ自動スクロール
                                            proxy.scrollTo(studyViewModel.transcriptDetail[newIndex].id, anchor: .center)
                                        }
                                    }
                                })
                                
                                // 右下に翻訳リスト表示ボタン配置
                                Button(action: {
                                    isShowSheet.toggle()
                                }) {
                                    VStack {
                                        Spacer()
                                        HStack {
                                            Spacer()
                                            Text("翻訳リスト")
                                                .font(.headline)
                                                .foregroundColor(.white)
                                                .padding(.horizontal, 24)
                                                .padding(.vertical, 12)
                                                .background(
                                                    Capsule()
                                                        .fill(ColorCodes.primary.color())
                                                        .shadow(color: .gray.opacity(0.7), radius: 5, x: 0, y: 5)
                                                )
                                        }
                                    }
                                }
                                .padding([.bottom, .trailing])
                                .buttonStyle(PlainButtonStyle()) // ボタン枠内をタップ領域にする
                                .sheet(isPresented: $isShowSheet) {
                                    TranslateView(studyViewModel: studyViewModel)
                                        .background(.gray.opacity(0.2))
                                        .presentationDetents(
                                            [.medium, .large]
                                        )
                                }
                                .presentationDetents([.medium])
                                .offset(y: showMenuTabBar ? -49 : 0)
                                .animation(.easeInOut(duration: 0.3), value: showMenuTabBar)
                            }
                        } else {
                            // 字幕表示モードが.hideAllの場合
                            VStack {
                                Spacer()
                                Text("字幕非表示中")
                                    .foregroundColor(Color(white: 0.5))
                                    .font(.headline)
                                Spacer()
                            }
                        }
                    }
                }
                
                ZStack {
                    
                    MenuTabBarView(
                        isTranscriptSync: $studyViewModel.isTranscriptSync, 
                        toggleTranslateEditIcon: { showTranslateEditIcon.toggle() },
                        changePlaybackRate: { studyViewModel.changePlayBackRate() },
                        playBackRate: studyViewModel.playBackRate,
                        changeDisplayMode: { studyViewModel.changeTranscriptDisplayMode() }
                    )
                    .offset(y: showMenuTabBar ? -49 : 0)
                    .animation(.easeInOut(duration: 0.3), value: showMenuTabBar)
                    
                    StudyTabBarView(
                        showMenuTabBar: $showMenuTabBar,
                        rewindAction: { studyViewModel.rewind() },
                        pauseAction: { studyViewModel.togglePlayback() },
                        fastForwardAction: { studyViewModel.fastForward()},
                        repeatAction: { studyViewModel.startRepeat() },
                        stopRepeatAction: { studyViewModel.stopRepeat() },
                        isPaused: studyViewModel.isPaused,
                        isRepeating: studyViewModel.isRepeating
                    )
                    .background(.white)
                }
            }
            .onAppear {
                studyViewModel.statusViewModel = StatusViewModel(isLoading: true)
                // 動画がすでに保存されている場合は、DBに保存したtranscriptsを取得
                if videoInfo.isVideoAlradySaved {
                    studyViewModel.getSavedTranscript(videoId: videoInfo.videoId)
                } else {
                    studyViewModel.getTranscripts(videoId: videoInfo.videoId)
                }
            }
            // 字幕編集画面
            if showEditDialog {
                EditDialogView(
                    editedEnSubtitle: transcriptDetailModel?.enSubtitle,
                    editedJaSubtitle: transcriptDetailModel?.jaSubtitle,
                    isPresented: $showEditDialog,
                    onConfirm: { editedEnSubtitle, editedJaSubtitle in
                        if var transcriptDetailModel = self.transcriptDetailModel, let index = studyViewModel.transcriptDetail.firstIndex(where: {
                            // 編集したtranscriptのidと一致するindexを取得
                            $0.id == transcriptDetailModel.id
                        }) {
                            // 編集した英語/日本語字幕で上書き
                            transcriptDetailModel.enSubtitle = editedEnSubtitle
                            transcriptDetailModel.jaSubtitle = editedJaSubtitle
                            // 編集したtranscriptで上書き @Publishedにより、変更を発行
                            studyViewModel.transcriptDetail[index] = transcriptDetailModel
                        }
                    })
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    // 動画がすでに保存されている場合は、DB更新
                    videoInfo.isVideoAlradySaved ?
                    studyViewModel.update(videoInfo: videoInfo) :
                    studyViewModel.store(videoInfo: videoInfo)
                    
                } label: {
                    Text("保存/終了")
                }
            }
        }
    }
}
