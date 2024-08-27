//
//  PlayVideoViewModel.swift
//  SwiftUIApp
//
//  Created by 鈴木 健太 on 2024/08/21.
//

import SwiftUI
import Combine
import YouTubePlayerKit

// 字幕表示モード
enum TranscriptDisplayMode {
    case showAll // 字幕全て表示
    case hideEnglish // 英語字幕のみ非表示
    case hideJapanese // 日本語字幕のみ非表示
    case hideAll // 字幕全て非表示
}
}

class StudyViewModel: ObservableObject {
    
    private let apiService: APIServiceType
    
    var youTubePlayer: YouTubePlayer
    
    var cancellableBag = Set<AnyCancellable>()
    
    private var timerCancellable: Cancellable?
    
    // リピートタスクの管理用プロパティ
    private var repeatTask: Task<Void, Never>?
    
    // 字幕情報が格納されたモデル
    @Published var transcriptDetail: [TranscriptModel.TranscriptDetailModel] = []
    
    // 現在表示すべき字幕のインデックス
    @Published var currentTranscriptIndex: Int?
    
    // 動画が一時停止中かどうか
    @Published var isPaused: Bool = false
    
    // リピート中かどうか
    @Published var isRepeating: Bool = false
    
    // 字幕同期中かどうか
    @Published var isTranscriptSync: Bool = false
    
    // 字幕の表示モード
    @Published var transcriptDisplayMode: TranscriptDisplayMode = .showAll
    
    // 再生速度
    @Published var playBackRate: PlayBackRate = .normal

    init(apiService: APIServiceType, url: YouTubePlayer) {
        self.apiService = apiService
        self.youTubePlayer = url
        
        // 動画の現在の時間を発行する
        youTubePlayer.currentTimePublisher()
            .receive(on: RunLoop.main)
            .sink { [weak self] currentTime in
                guard let self = self, !self.isRepeating else { return }
                let currentTime = currentTime.value
                print("現在の時間: \(currentTime)")
                self.updateCurrentTranscriptIndex(for: currentTime)
            }
            .store(in: &cancellableBag)
        
        // 動画のステータスを発行する
        youTubePlayer.playbackStatePublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] state in
                guard let self = self else { return }
                if state == .paused {
                    self.startTimer()
                    self.isPaused = true
                } else {
                    self.isPaused = false
                    self.stopTimer()
                }
            }
            .store(in: &cancellableBag)
    }
    
    deinit {
        cancellableBag.removeAll()
        stopTimer()
        stopRepeat()
    }
}

extension StudyViewModel {
    
    // ハイライトされる字幕のindexを更新
    func updateCurrentTranscriptIndex(for currentTime: Double) {
        // 字幕同期が無効であればreturn
        guard !isTranscriptSync else { return }
        
        if let index = transcriptDetail.firstIndex(where: { $0.start <= currentTime && currentTime < $0.start + $0.duration }) {
            currentTranscriptIndex = index
        } else {
            currentTranscriptIndex = nil
        }
    }
    
    // 共通のシーク処理
    private func seek(to measurement: Measurement<UnitDuration>) {
        youTubePlayer.seek(to: measurement, allowSeekAhead: true)
    }
    
    // 指定の時間へシーク
    func seekToTranscript(at index: Int) {
        guard index >= 0 && index < transcriptDetail.count else { return }
        // リピート中に字幕が押下された場合
        if isRepeating {
            startRepeat()
        }
        // タップされたリストのtranscripの開始時間取得
        let startTime = transcriptDetail[index].start
        let measurement = Measurement(value: startTime, unit: UnitDuration.seconds)
        seek(to: measurement)
    }
    
    // 巻き戻し/早送り
    func seek(by seconds: Double) {
        Task {
            do {
                let currentTime = try await youTubePlayer.getCurrentTime()
                let measurement = Measurement(value: seconds, unit: UnitDuration.seconds)
                let newMeasurement = Measurement(value: currentTime.value + measurement.value, unit: UnitDuration.seconds)
                seek(to: newMeasurement)
            } catch {
                print("Error seeking video: \(error)")
            }
        }
    }
    
    // 3秒巻き戻し 秒数は固定
    func rewind() {
        seek(by: -3.0)
    }
    
    // 3秒早送り 秒数は固定
    func fastForward() {
        seek(by: 3.0)
    }
    
    // リピート開始
    func startRepeat() {
        guard let index = currentTranscriptIndex else { return }
        let transcript = transcriptDetail[index] // 指定のtranscript取得
        let startTime = transcript.start // 字幕表示開始時間
        let duration = transcript.duration // 字幕表示時間
        let measurement = Measurement(value: startTime, unit: UnitDuration.seconds)
        
        isRepeating = true
        
        // 前のリピートタスクがあればキャンセル
        repeatTask?.cancel()
        
        repeatTask = Task {
            do {
                // 無限ループでリピートを続ける
                while isRepeating {
                    seek(to: measurement)
                    // 指定の時間待機
                    try await Task.sleep(nanoseconds: UInt64(duration * 1_000_000_000))
                    // リピートの準備を整えるために再度シーク
                    seek(to: measurement)
                }
            } catch {
                print("Error repeating transcript: \(error)")
            }
        }
    }
    
    // リピートを停止
    func stopRepeat() {
        repeatTask?.cancel()
        isRepeating = false
    }
    
    // 再開/一時停止の切り替え
    func togglePlayback() {
        Task {
            do {
                if isPaused {
                    // 再開
                    try await youTubePlayer.play()
                    isPaused = false
                } else {
                    // 一時停止
                    try await youTubePlayer.pause()
                    isPaused = true
                }
            } catch {
                print("Error toggling playback: \(error)")
            }
        }
    }
    
    
    // １秒ごとに動画の現在の時間を取得する 動画が停止(.pause)されたら呼ばれる
    private func startTimer() {
        stopTimer()
        timerCancellable = Timer.publish(every: 1.0, on: .main, in: .default)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                Task {
                    do {
                        // 現在の時間を取得
                        let currentTime = try await self.youTubePlayer.getCurrentTime()
                        DispatchQueue.main.async {
                            // ハイライトされる字幕のindexを更新
                            self.updateCurrentTranscriptIndex(for: currentTime.value)
                        }
                    } catch {
                        print("Error fetching current time: \(error)")
                    }
                }
            }
    }
    
    // タイマー停止
    private func stopTimer() {
        timerCancellable?.cancel()
        timerCancellable = nil
    }
    
    // 表示モードを順番に切り替えるメソッド
    func changeTranscriptDisplayMode() {
        switch transcriptDisplayMode {
        case .showAll:
            transcriptDisplayMode = .hideEnglish
        case .hideEnglish:
            transcriptDisplayMode = .hideJapanese
        case .hideJapanese:
            transcriptDisplayMode = .hideAll
        case .hideAll:
            transcriptDisplayMode = .showAll
        }
    }
}

extension StudyViewModel {
    
    // 字幕取得
    internal func getTranscripts(videoId: String) -> Void {
        // 字幕取得処理リクエスト組み立て
        let getTranscriptRequest = GetTranscriptRequest(videoId: videoId)
        // リクエスト
        apiService.request(with: getTranscriptRequest)
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { [weak self] completion in
                guard let self = self else { return }
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    break
                }
            }, receiveValue: { [weak self] value in
                guard let self = self, let transcriptModel = TranscriptModel.handleResponse(value: value) else { return }
                self.transcriptDetail = transcriptModel.transcripts
            })
            .store(in: &cancellableBag)
    }
}
