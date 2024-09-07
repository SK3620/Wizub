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

// 再生速度
enum PlayBackRate: Double {
    case normal = 1.0 // 通常
    case fast = 1.25 // 早い
    case slow = 0.75 // 遅い
    
    func toString() -> String {
        switch self {
        case .normal:
            return "1.0x"
        case .fast:
            return "1.25x"
        case .slow:
            return "0.75x"
        }
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
    
    // 画面の状態を発行
    @Published var statusViewModel: StatusViewModel = StatusViewModel(isLoading: false, shouldTransition: false, showErrorMessage: false, alertErrorMessage: "")
    
    // 編集ダイアログを表示するかどうか
    @Published var showEditDialog: Bool = false
    
    // 編集するtranscript
    @Published var editedTranscriptDeital: TranscriptModel.TranscriptDetailModel?
    
    // 押下されたtranscriptを発行するPublisher（append）
    var translateButtonPressed = PassthroughSubject<TranscriptModel.TranscriptDetailModel, Never>()
    
    // 押下されたtranscriptを発行するPublisher（remove）
    var removeTranscriptButtonPressed = PassthroughSubject<TranscriptModel.TranscriptDetailModel, Never>()
    
    // 押下されたtranscriptを保持する配列
    @Published var translatedTranscripts: [TranscriptModel.TranscriptDetailModel] = []
    
    // 翻訳レスポンスを発行する
    @Published var translatedSubtitles: [JaTranslation] = []
    
    init(apiService: APIServiceType, youTubePlayer: YouTubePlayer) {
        self.apiService = apiService
        self.youTubePlayer = youTubePlayer
        
        // 動画の現在の時間を発行する
        youTubePlayer.currentTimePublisher()
            .receive(on: RunLoop.main)
            .sink { [weak self] currentTime in
                guard let self = self, !self.isRepeating else { return }
                let currentTime = currentTime.value
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
        
        // 押下されたtranscriptを発行する
        translateButtonPressed
            .receive(on: RunLoop.main)
            .sink { [weak self] transcript in
                guard let self = self else { return }
                // 配列に格納
                self.translatedTranscripts.append(transcript)
            }
            .store(in: &cancellableBag)
        
        // 押下されたtranscriptを発行する
        removeTranscriptButtonPressed
            .receive(on: RunLoop.main)
            .sink { [weak self] transcript in
                guard let self = self else { return }
                // 配列から除外
                self.translatedTranscripts.removeAll { $0.id == transcript.id }
                print(self.translatedTranscripts)
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
        
        for i in 0..<transcriptDetail.count - 1 {
            if currentTime >= transcriptDetail[i].start && currentTime < transcriptDetail[i + 1].start {
                currentTranscriptIndex = i
                break
            } else {
                currentTranscriptIndex = nil
            }
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
        
        let firstTranscript = transcriptDetail[index] // 指定のtranscript取得
        let nextTranscript = transcriptDetail[index + 1] //次のtranscript取得
        
        let firstTrStartTime = firstTranscript.start // 字幕表示開始時間
        let nextTrStartTime = nextTranscript.start // 字幕表示開始時間
        
        let duration = nextTrStartTime - firstTrStartTime
        
        let measurement = Measurement(value: firstTrStartTime, unit: UnitDuration.seconds)
        
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
    
    // 表示モードを順番に切り替え
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
    
    // 再生速度切り替え
    func changePlayBackRate() {
        switch playBackRate {
        case .normal:
            playBackRate = .fast
        case .fast:
            playBackRate = .slow
        case .slow:
            playBackRate = .normal
        }
        
        youTubePlayer.set(playbackRate: playBackRate.rawValue)
    }
}

extension StudyViewModel {
    
    // 字幕取得
    func getTranscripts(videoId: String) -> Void {
        // 字幕取得処理リクエスト組み立て
        let getTranscriptRequest = GetTranscriptsRequest(videoId: videoId)
        // リクエスト
        apiService.request(with: getTranscriptRequest)
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { [weak self] completion in
                guard let self = self else { return }
                switch completion {
                case .finished:
                    self.statusViewModel = StatusViewModel(isLoading: false)
                    break
                case .failure(let error):
                    let errorMessage = "この動画には字幕が含まれていません"
                    self.statusViewModel = StatusViewModel(isLoading: false, showErrorMessage: true, alertErrorMessage: errorMessage)
                    break
                }
            }, receiveValue: { [weak self] value in
                guard let self = self, let transcriptModel = TranscriptModel.handleResponse(value: value) else { return }
                // idが小さい順にsort
                self.transcriptDetail = transcriptModel.transcripts.sorted(by: { $0.id < $1.id })
            })
            .store(in: &cancellableBag)
    }
    
    // DBに保存済みの字幕取得
    func getSavedTranscript(videoId: String) {
        // リクエスト組み立て
        let getSavedTranscriptsRequest = GetSavedTranscritpsRequest(videoId: videoId)
        
        // リクエスト
        apiService.request(with: getSavedTranscriptsRequest)
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { [weak self] completion in
                guard let self = self else { return }
                switch completion {
                case .finished:
                    self.statusViewModel = StatusViewModel(isLoading: false)
                    break
                case .failure(let error):
                    let errorMessage = "この動画には字幕が含まれていません"
                    self.statusViewModel = StatusViewModel(isLoading: false, showErrorMessage: true, alertErrorMessage: errorMessage)
                    break
                }
            }, receiveValue: { [weak self] value in
                guard let self = self, let transcriptModel = TranscriptModel.handleResponse(value: value) else { return }
                // idが小さい順にsort
                self.transcriptDetail = transcriptModel.transcripts.sorted(by: { $0.id < $1.id })
            })
            .store(in: &cancellableBag)
    }
    
    // 翻訳
    func translate(translatedTranscript2: [TranscriptModel.TranscriptDetailModel]) -> Void {
        
        // 質問内容組み立て
        var content: String = ""
        translatedTranscript2.forEach {
            content += "''''(ID:\($0.id)) \($0.enSubtitle)'''\n"
        }
        let translateRequest = TranslateRequest(content: content)
        
        apiService.request(with: translateRequest)
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { [weak self] completion in
                guard let self = self else { return }
                switch completion {
                case .finished:
                    self.statusViewModel = StatusViewModel(isLoading: false)
                    break
                case .failure(let error):
                    let errorMessage = "翻訳に失敗しました。再度お試しください。"
                    self.statusViewModel = StatusViewModel(isLoading: false, showErrorMessage: true, alertErrorMessage: errorMessage)
                    break
                }
            }, receiveValue: { [weak self] value in
                guard let self = self, let openAIResponseModel = OpenAIResponseModel.handleResponse(value: value) else  { return }
                
                // answerは[id: 日本語字幕]の形式
                let answer: [String: String] = openAIResponseModel.answer

                // 新しい配列を作成して更新
                var updatedTranscripts = transcriptDetail

                // answerに含まれる字幕IDに対応する日本語字幕を、updatedTranscripts配列の該当する要素に上書き
                for (idString, jaSubtitle) in answer {
                    if let id = Int(idString) {
                        if let index = updatedTranscripts.firstIndex(where: { $0.id == id }) {
                            updatedTranscripts[index].jaSubtitle = jaSubtitle
                        }
                    }
                }

                // 更新された配列を再代入して、変更を発行
                transcriptDetail = updatedTranscripts
            })
            .store(in: &cancellableBag)
    }
    
    // DBに動画＆字幕情報の保存
    func store(videoInfo: CardView.VideoInfo) {
        // 動画のID
        let videoId = videoInfo.videoId
        // 動画のタイトル
        let title = videoInfo.title
        // 動画のサムネイル
        let thumbnailUrl = videoInfo.thumbnailURL
        
        // リクエスト組み立て
        let storeTranscriptRequestModel = StoreTranscriptRequestModel(videoId: videoId, title: title, thumbnailUrl: thumbnailUrl, transcripts: transcriptDetail)
        let storeTranscriptRequest = StoreTranscriptsRequest(model: storeTranscriptRequestModel)
        
        apiService.request(with: storeTranscriptRequest)
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { [weak self] completion in
                guard let self = self else { return }
                switch completion {
                case .finished:
                    self.statusViewModel = StatusViewModel(isLoading: false)
                    break
                case .failure(let error):
                    self.statusViewModel = StatusViewModel(isLoading: false, showErrorMessage: true, alertErrorMessage: error.localizedDescription)
                    break
                }
            }, receiveValue: { _ in
                
            })
            .store(in: &cancellableBag)
    }
    
    // DB更新
    func update(videoInfo: CardView.VideoInfo) {
        // 更新対象のレコードID
        guard let id = videoInfo.id else { return }
        let transciptModel = TranscriptModel(transcripts: transcriptDetail)
        let updateTranscriptsRequest = UpdateTranscriptRequest(id: id, model: transciptModel)
        
        apiService.request(with: updateTranscriptsRequest)
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { [weak self] completion in
                guard let self = self else { return }
                switch completion {
                case .finished:
                    self.statusViewModel = StatusViewModel(isLoading: false)
                    break
                case .failure(let error):
                    self.statusViewModel = StatusViewModel(isLoading: false, showErrorMessage: true, alertErrorMessage: error.localizedDescription)
                    break
                }
            }, receiveValue: { _ in
               print("updated successfully")
            })
            .store(in: &cancellableBag)
    }
}
