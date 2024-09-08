//
//  PlayVideoViewModel.swift
//  SwiftUIApp
//
//  Created by 鈴木 健太 on 2024/08/21.
//

import SwiftUI
import Combine
import YouTubePlayerKit

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
    
    enum ApiEvent {
        // 字幕取得
        case getSubtitles(videoId: String)
        // DBに保存した字幕取得
        case getSavedSubtitles(videoId: String)
        // 翻訳
        case translate(pendingTranslatedSubtitles: [SubtitleModel.SubtitleDetailModel])
        // DBに動画＆字幕情報の保存
        case store(videoInfo: CardView.VideoInfo)
        // DBに保存した字幕情報更新
        case update(id: Int)
    }
    
    func apply(event: ApiEvent) {
        switch event {
        case .getSubtitles(let videoId):
            getSubtitles(videoId: videoId)
        case .getSavedSubtitles(let videoId):
            getSavedSubtitles(videoId: videoId)
        case .translate(let pendingTranslatedSubtitles):
            translate(pendingTranslatedSubtitles: pendingTranslatedSubtitles)
        case .store(let videoInfo):
            store(videoInfo: videoInfo)
        case .update(let id):
            update(id: id)
        }
    }
    
    private let apiService: APIServiceType
    
    var youTubePlayer: YouTubePlayer
    
    var cancellableBag = Set<AnyCancellable>()
    
    private var timerCancellable: Cancellable?
    
    // リピートタスクの管理用プロパティ
    private var repeatTask: Task<Void, Never>?
    
    private let httpErrorSubject = PassthroughSubject<HttpError, Never>()
    
    @Published var isLoading: Bool = false
    @Published var isSuccess: Bool = false
    @Published var isShowError: Bool = false
    @Published var httpErrorMsg: String = ""
    
    // 字幕情報が格納されたモデル
    @Published var subtitleDetails: [SubtitleModel.SubtitleDetailModel] = []
    
    // 現在表示すべき字幕のインデックス
    @Published var currentSubtitleIndex: Int?
    
    // 動画が一時停止中かどうか
    @Published var isPaused: Bool = false
    
    // リピート中かどうか
    @Published var isRepeating: Bool = false
    
    // 字幕同期中かどうか
    @Published var isSubtitleSync: Bool = false
    
    // 再生速度
    @Published var playBackRate: PlayBackRate = .normal
    
    // 編集ダイアログを表示するかどうか
    @Published var showEditDialog: Bool = false
    
    // 編集する字幕
    @Published var editedSubtitleDetail: SubtitleModel.SubtitleDetailModel?
    
    // 押下された字幕を発行するPublisher（append）
    var translateButtonPressed = PassthroughSubject<SubtitleModel.SubtitleDetailModel, Never>()
    
    // 押下された字幕を発行するPublisher（remove）
    var removeSubtitleButtonPressed = PassthroughSubject<SubtitleModel.SubtitleDetailModel, Never>()
    
    // 押下された字幕を保持する配列
    @Published var pendingTranslatedSubtitles: [SubtitleModel.SubtitleDetailModel] = []
    
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
                self.updateCurrentSubtitleIndex(for: currentTime)
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
        
        // 押下された字幕を発行する
        translateButtonPressed
            .receive(on: RunLoop.main)
            .sink { [weak self] subtitleDetail in
                guard let self = self else { return }
                // 配列に格納
                self.pendingTranslatedSubtitles.append(subtitleDetail)
            }
            .store(in: &cancellableBag)
        
        // 押下された字幕を発行する
        removeSubtitleButtonPressed
            .receive(on: RunLoop.main)
            .sink { [weak self] subtitleDetail in
                guard let self = self else { return }
                // 配列から除外
                self.pendingTranslatedSubtitles.removeAll { $0.id == subtitleDetail.id }
            }
            .store(in: &cancellableBag)
        
        httpErrorSubject
            .sink(receiveValue: { [weak self] (error) in
                guard let self = self else { return }
                self.isLoading = false
                self.isSuccess = false
                self.isShowError = true
                self.httpErrorMsg = error.localizedDescription
            })
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
    func updateCurrentSubtitleIndex(for currentTime: Double) {
        // 字幕同期が無効であればreturn
        guard !isSubtitleSync else { return }
        
        for i in 0..<subtitleDetails.count - 1 {
            if currentTime >= subtitleDetails[i].start && currentTime < subtitleDetails[i + 1].start {
                currentSubtitleIndex = i
                break
            } else {
                currentSubtitleIndex = nil
            }
        }
    }
    
    // 共通のシーク処理
    private func seek(to measurement: Measurement<UnitDuration>) {
        youTubePlayer.seek(to: measurement, allowSeekAhead: true)
    }
    
    // 指定の時間へシーク
    func seekToSubtitle(at index: Int) {
        guard index >= 0 && index < subtitleDetails.count else { return }
        // リピート中に字幕が押下された場合
        if isRepeating {
            startRepeat()
        }
        // タップされたリストの字幕の開始時間取得
        let startTime = subtitleDetails[index].start
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
        guard let index = currentSubtitleIndex else { return }
        
        let firstSubtitle = subtitleDetails[index] // 指定の字幕取得
        let nextSubtitle = subtitleDetails[index + 1] //次の字幕取得
        
        let firstSubtitleStartTime = firstSubtitle.start // 字幕表示開始時間
        let nextSubtitleStartTime = nextSubtitle.start // 字幕表示開始時間
        
        let duration = nextSubtitleStartTime - firstSubtitleStartTime
        
        let measurement = Measurement(value: firstSubtitleStartTime, unit: UnitDuration.seconds)
        
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
                            self.updateCurrentSubtitleIndex(for: currentTime.value)
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
   private func getSubtitles(videoId: String) -> Void {
        // 字幕取得処理リクエスト組み立て
        let getSubtitlesRequest = GetSubtitlesRequest(videoId: videoId)
        // リクエスト
        apiService.request(with: getSubtitlesRequest)
            .receive(on: RunLoop.main)
            .catch { [weak self] (error) -> Empty<Decodable, Never> in
                // 上流Publisherのエラーをcatch 別のPublisherへエラーを流す
                self?.httpErrorSubject.send(error)
                // 空のPublisherに置き換えストリームを中断
                return .init()
            }
            .sink(receiveValue: { [weak self] value in
                guard let self = self, let subtitleModel = SubtitleModel.handleResponse(value: value) else { return }
                // idが小さい順にsort
                self.subtitleDetails = subtitleModel.subtitles.sorted(by: { $0.id < $1.id })
                self.isLoading = false
                self.isSuccess = true
            })
            .store(in: &cancellableBag)
    }
    
    // DBに保存済みの字幕取得
   private func getSavedSubtitles(videoId: String) {
        // リクエスト組み立て
        let getSavedSubtitlesRequest = GetSavedSubtitlesRequest(videoId: videoId)
        
        // リクエスト
        apiService.request(with: getSavedSubtitlesRequest)
            .receive(on: RunLoop.main)
            .catch { [weak self] (error) -> Empty<Decodable, Never> in
                // 上流Publisherのエラーをcatch 別のPublisherへエラーを流す
                self?.httpErrorSubject.send(error)
                // 空のPublisherに置き換えストリームを中断
                return .init()
            }
            .sink(receiveValue: { [weak self] value in
                guard let self = self, let subtitleModel = SubtitleModel.handleResponse(value: value) else { return }
                // idが小さい順にsort
                self.subtitleDetails = subtitleModel.subtitles.sorted(by: { $0.id < $1.id })
                self.isLoading = false
                self.isSuccess = true
            })
            .store(in: &cancellableBag)
    }
    
    // 翻訳
    private func translate(pendingTranslatedSubtitles: [SubtitleModel.SubtitleDetailModel]) -> Void {
        // 質問内容組み立て
        var content: String = ""
        pendingTranslatedSubtitles.forEach {
            content += "''''(ID:\($0.id)) \($0.enSubtitle)'''\n"
        }
        let translateRequest = TranslateRequest(content: content)
        
        apiService.request(with: translateRequest)
            .receive(on: RunLoop.main)
            .catch { [weak self] (error) -> Empty<Decodable, Never> in
                // 上流Publisherのエラーをcatch 別のPublisherへエラーを流す
                self?.httpErrorSubject.send(error)
                // 空のPublisherに置き換えストリームを中断
                return .init()
            }
            .sink(receiveValue: { [weak self] value in
                guard let self = self, let openAIResponseModel = OpenAIResponseModel.handleResponse(value: value) else  { return }
                // answerは[id: 日本語字幕]の形式
                let answer: [String: String] = openAIResponseModel.answer
                // 新しい配列を作成して更新
                var updatedSubtitleDetails = subtitleDetails
                // answerに含まれる字幕IDに対応する日本語字幕を、updatedSubtitleDetails配列の該当する要素に上書き
                for (idString, jaSubtitle) in answer {
                    if let id = Int(idString) {
                        if let index = updatedSubtitleDetails.firstIndex(where: { $0.id == id }) {
                            updatedSubtitleDetails[index].jaSubtitle = jaSubtitle
                        }
                    }
                }
                // 更新された配列を再代入して、変更を発行
                subtitleDetails = updatedSubtitleDetails
                
                self.isLoading = false
                self.isSuccess = true
            })
            .store(in: &cancellableBag)
    }
    
    // DBに動画＆字幕情報の保存
   private func store(videoInfo: CardView.VideoInfo) {
        // 動画のID
        let videoId = videoInfo.videoId
        // 動画のタイトル
        let title = videoInfo.title
        // 動画のサムネイル
        let thumbnailUrl = videoInfo.thumbnailURL
        
        // リクエスト組み立て
        let storeSubtitlesRequestModel = StoreSubtitlesRequestModel(videoId: videoId, title: title, thumbnailUrl: thumbnailUrl, subtitles: subtitleDetails)
        let storeSubtitlesRequest = StoreSubtitlesRequest(model: storeSubtitlesRequestModel)
        
        apiService.request(with: storeSubtitlesRequest)
            .receive(on: RunLoop.main)
            .catch { [weak self] (error) -> Empty<Decodable, Never> in
                // 上流Publisherのエラーをcatch 別のPublisherへエラーを流す
                self?.httpErrorSubject.send(error)
                // 空のPublisherに置き換えストリームを中断
                return .init()
            }
            .sink(receiveValue: { [weak self] _ in
                guard let self = self else { return }
                self.isLoading = false
                self.isSuccess = true
            })
            .store(in: &cancellableBag)
    }
    
    // DB更新
    private func update(id: Int) {
        let subtitleModel = SubtitleModel(subtitles: subtitleDetails)
        let updateSubtitlesRequest = UpdateSubtitlesRequest(id: id, model: subtitleModel)
        
        apiService.request(with: updateSubtitlesRequest)
            .receive(on: RunLoop.main)
            .catch { [weak self] (error) -> Empty<Decodable, Never> in
                // 上流Publisherのエラーをcatch 別のPublisherへエラーを流す
                self?.httpErrorSubject.send(error)
                // 空のPublisherに置き換えストリームを中断
                return .init()
            }
            .sink(receiveValue: { [weak self] _ in
                guard let self = self else { return }
                self.isLoading = false
                self.isSuccess = true
            })
            .store(in: &cancellableBag)
    }
}
