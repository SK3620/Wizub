//
//  VideoPlayView.swift
//  SwiftUIApp
//
//  Created by 鈴木 健太 on 2024/08/21.
//

import SwiftUI
import YouTubePlayerKit
import Algorithms

struct StudyView: View {
    
    @StateObject var studyViewModel: StudyViewModel
    
    @State private var showMenuTabBar = false
    
    @State private var isShowSheet = false
    
    // 編集/翻訳アイコンを表示するかどうか
    @State private var showTranslateEditIcon = false
    
    // 編集画面を表示するかどうか
    @State private var showEditDialog = false
    
    // 編集する字幕
    @State private var editedSubtitleDetail: SubtitleModel.SubtitleDetailModel?
    
    // リスト内で押下された動画の情報
    private let videoInfo: VideoListRow.VideoInfo
    
    // 現在の画面を閉じて前の画面に戻るための環境変数
    @Environment(\.dismiss) var dismiss
    
    init(videoInfo: VideoListRow.VideoInfo) {
        self.videoInfo = videoInfo
        // '_' @StateObjectプロパティラッパーのバックアップストア（内部でデータを保持している場所）にアクセス
        _studyViewModel = StateObject(wrappedValue: StudyViewModel(apiService: APIService(), youTubePlayer: YouTubePlayer(stringLiteral: "https://youtube.com/watch?v=\(videoInfo.videoId)")))
    }
    
    var body: some View {
        ZStack {
            VStack {
                
                PlayVideoView(studyViewModel: studyViewModel)
                
                if studyViewModel.isLoading {
                    VStack {
                        Spacer()
                        CommonProgressView()
                        Spacer()
                    }
                } else {
                    ScrollViewReader { proxy in
                        ZStack {
                            List {
                                ForEach(Array(studyViewModel.subtitleDetails.enumerated()), id: \.offset){
                                    index, subtitleDetail in
                                    SubtitleListView(
                                        subtitleDetails: subtitleDetail,
                                        isHighlighted: studyViewModel.currentSubtitleIndex == index,
                                        showTranslateEditIcon: showTranslateEditIcon,
                                        storeSubtitles: {
                                            studyViewModel.translateButtonPressed.send(subtitleDetail)
                                        },
                                        removeSubtitle: {
                                            studyViewModel.removeSubtitleButtonPressed.send(subtitleDetail)
                                        },
                                        editSubtitle: { showEditDialog in
                                            // 編集する字幕
                                            self.editedSubtitleDetail = subtitleDetail
                                            // 編集画面の表示フラグ
                                            self.showEditDialog = showEditDialog
                                        }
                                    )
                                    .onTapGesture {
                                        // ハイライトされる字幕を更新
                                        studyViewModel.currentSubtitleIndex = index
                                        studyViewModel.seekToSubtitle(at: index)
                                    }
                                }
                            }
                            .listStyle(.inset)
                            // subtitleのindexの変更を監視
                            .onChange(of: studyViewModel.currentSubtitleIndex, { oldIndex, newIndex in
                                if let newIndex = newIndex {
                                    withAnimation {
                                        // 指定の字幕へ自動スクロール
                                        proxy.scrollTo(studyViewModel.subtitleDetails[newIndex].id, anchor: .center)
                                    }
                                }
                            })
                            
                            // 右下に翻訳リスト表示ボタン配置
                            ShowTranslateViewButton(
                                isShowTranslateView: { isShowSheet.toggle() }
                            )
                            .padding([.bottom, .trailing])
                            .buttonStyle(PlainButtonStyle()) // ボタン枠内をタップ領域にする
                            .offset(y: showMenuTabBar ? -49 : 0)
                            .animation(.easeInOut(duration: 0.3), value: showMenuTabBar)
                            .sheet(isPresented: $isShowSheet) {
                                // 翻訳リストシート
                                TranslateView(pendingTranslatedSubtitles: studyViewModel.pendingTranslatedSubtitles,
                                              allSubtitles: studyViewModel.subtitleDetails,
                                              translateSelected: { studyViewModel.apply(event: .translate(subtitles: studyViewModel.pendingTranslatedSubtitles)) },
                                              translateAll: { studyViewModel.apply(event: .translate(subtitles: studyViewModel.subtitleDetails)) })
                                .background(.gray.opacity(0.2))
                                .presentationDetents(
                                    [.medium, .large]
                                )
                            }
                        }
                    }
                }
                
                ZStack {
                    
                    MenuTabBarView(
                        isSubtitleSync: $studyViewModel.isSubtitleSync,
                        toggleTranslateEditIcon: { showTranslateEditIcon.toggle() },
                        changePlaybackRate: { studyViewModel.changePlayBackRate() },
                        playBackRate: studyViewModel.playBackRate
                    )
                    .offset(y: showMenuTabBar ? -49 : 0)
                    .animation(.easeInOut(duration: 0.3), value: showMenuTabBar)
                    
                    StudyTabBarView(
                        showMenuTabBar: { showMenuTabBar.toggle() },
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
                let videoId = videoInfo.videoId
                // 動画がすでに保存されている場合は、DBに保存した字幕を取得
                videoInfo.isVideoAlradySaved ?
                studyViewModel.apply(event: .getSavedSubtitles(videoId: videoId)) :
                studyViewModel.apply(event: .getSubtitles(videoId: videoId))
            }
            // 字幕編集画面
            if showEditDialog {
                EditDialogView(
                    editedEnSubtitle: editedSubtitleDetail?.enSubtitle,
                    editedJaSubtitle: editedSubtitleDetail?.jaSubtitle,
                    isPresented: $showEditDialog,
                    onConfirm: { editedEnSubtitle, editedJaSubtitle in
                        if var editedSubtitleDetail = self.editedSubtitleDetail, let index = studyViewModel.subtitleDetails.firstIndex(where: {
                            // 編集した字幕のidと一致するindexを取得
                            $0.id == editedSubtitleDetail.id
                        }) {
                            // 編集した英語/日本語字幕で上書き
                            editedSubtitleDetail.enSubtitle = editedEnSubtitle
                            editedSubtitleDetail.jaSubtitle = editedJaSubtitle
                            // 編集した字幕で上書き @Publishedにより、変更を発行
                            studyViewModel.subtitleDetails[index] = editedSubtitleDetail
                        }
                    })
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    if let id = videoInfo.id, videoInfo.isVideoAlradySaved {
                        // 動画がすでに保存されている場合は、DB更新
                        studyViewModel.apply(event: .update(id: id))
                    } else {
                        studyViewModel.apply(event: .store(videoInfo: videoInfo))
                    }
                } label: {
                    Text("保存/終了")
                }
            }
        }
    }
}
