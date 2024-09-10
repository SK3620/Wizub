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
    
    // VideoListViewで押下された動画の情報を格納
    private let videoInfo: VideoListRow.VideoInfo
    
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
                                        isShowTranslateEditIcon: studyViewModel.isShowTranslateEditIcon,
                                        storeSubtitles: {
                                            studyViewModel.translateButtonPressed.send(subtitleDetail)
                                        },
                                        removeSubtitle: {
                                            studyViewModel.removeSubtitleButtonPressed.send(subtitleDetail)
                                        },
                                        editSubtitle: {
                                            // 編集する字幕を保持させておく
                                            studyViewModel.currentlyEditedSubtitleDetail = subtitleDetail
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
                                isShowTranslateView: { studyViewModel.isShowSheet.toggle() }
                            )
                            .padding([.bottom, .trailing])
                            .buttonStyle(PlainButtonStyle()) // ボタン枠内をタップ領域にする
                            .offset(y: studyViewModel.isShowMenuTabBar ? -49 : 0)
                            .animation(.easeInOut(duration: 0.3), value: studyViewModel.isShowMenuTabBar)
                            .sheet(isPresented: $studyViewModel.isShowSheet) {
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
                        toggleTranslateEditIcon: { studyViewModel.isShowTranslateEditIcon.toggle() },
                        changePlaybackRate: { studyViewModel.changePlayBackRate() },
                        playBackRate: studyViewModel.playBackRate
                    )
                    .offset(y: studyViewModel.isShowMenuTabBar ? -49 : 0)
                    .animation(.easeInOut(duration: 0.3), value: studyViewModel.isShowMenuTabBar)
                    
                    StudyTabBarView(
                        showMenuTabBar: { studyViewModel.isShowMenuTabBar.toggle() },
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
            if studyViewModel.isShowEditDialog {
                EditDialogView(
                    editedEnSubtitle: studyViewModel.currentlyEditedSubtitleDetail?.enSubtitle,
                    editedJaSubtitle: studyViewModel.currentlyEditedSubtitleDetail?.jaSubtitle,
                    editedMemo: studyViewModel.currentlyEditedSubtitleDetail?.memo,
                    isPresented: $studyViewModel.isShowEditDialog,
                    onConfirm: { editedEnSubtitle, editedJaSubtitle, memo in
                        // 編集処理
                        studyViewModel.editSubtitleButtonPressed.send((editedEnSubtitle, editedJaSubtitle, memo))
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
