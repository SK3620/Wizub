//
//  PlayVideoViewModel.swift
//  SwiftUIApp
//
//  Created by 鈴木 健太 on 2024/08/21.
//

import SwiftUI
import Combine
import YouTubePlayerKit

// MARK: - Playback Rate Enum
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

// MARK: - Kinds of success Enum
enum SuccessStatus {
    case dataSaved // データ保存/更新成功
    case subtitlesTranslated // ChatGPT翻訳処理成功
}


// MARK: - StudyViewModel
class StudyViewModel: ObservableObject {
    // MARK: - ApiEvent Enum
    enum ApiEvent {
        case getSubtitles(videoId: String) // 字幕取得
        case getSavedSubtitles(videoId: String) // DBに保存した字幕取得
        case translate(subtitles: [SubtitleModel.SubtitleDetailModel]) // 翻訳
        case store(videoInfo: VideoListRow.VideoInfo) // DBに動画＆字幕情報の保存
        case update(id: Int)  // DBに保存した字幕情報更新
    }
    
    // MARK: - Inputs
    // 押下された字幕を発行するPublisher（append）
    var appendSubtitleButtonPressed = PassthroughSubject<SubtitleModel.SubtitleDetailModel, Never>()
    // 押下された字幕を発行するPublisher（remove）
    var removeSubtitleButtonPressed = PassthroughSubject<SubtitleModel.SubtitleDetailModel, Never>()
    // 編集された英語/日本語字幕を発行するPublisher
    var editSubtitleButtonPressed = PassthroughSubject<(String, String, String), Never>()
    // エラーを発行するPublisher
    private let myAppErrorSubject = PassthroughSubject<MyAppError, Never>()
    
    // MARK: - Outputs
    // API通信ステータス
    @Published var isLoading: Bool = false
    @Published var loadingText = ""
    @Published var isSuccess: Bool = false
    @Published var successStatus: SuccessStatus?
    @Published var isShowError: Bool = false
    @Published var myAppErrorMsg: String = ""
    
    // 現在表示すべき字幕のインデックス
    @Published var currentSubtitleIndex: Int?
    // 動画が一時停止中かどうか
    @Published var isPaused: Bool = false
    // リピート中かどうか
    @Published var isRepeating: Bool = false
    // メニュータブバーを出現させるかどうか
    @Published var isShowMenuTabBar: Bool = false
    // 字幕同期中かどうか
    @Published var isSubtitleSync: Bool = false
    // 再生速度
    @Published var playBackRate: PlayBackRate = .normal
    // 編集/翻訳アイコンを表示するかどうか
    @Published var isShowTranslateEditIcon: Bool = false
    // 翻訳アイコンが全選択/全未選択かどうか
    @Published var isTranslateIconSelectedAll: Bool = false
    // 翻訳リストシートを表示するかどうか
    @Published var isShowSheet: Bool = false
    // 編集ダイアログを表示するかどうか
    @Published var isShowEditDialog: Bool = false
    
    // 字幕情報を格納する配列
    @Published var subtitleDetails: [SubtitleModel.SubtitleDetailModel] = []
    // （選択された）翻訳される字幕を保持する配列
    @Published var selectedTranslatedSubtitles: [SubtitleModel.SubtitleDetailModel] = []
    // 翻訳レスポンスを発行する
    @Published var translatedSubtitles: [JaTranslation] = []
    
    // 現在編集中の字幕を保持
    var currentlyEditedSubtitleDetail: SubtitleModel.SubtitleDetailModel? {
        didSet {
            // 編集する字幕がセットされたら字幕編集画面表示
            isShowEditDialog = true
        }
    }
    
    // MARK: - Dependencies
    private let apiService: APIServiceType
    var youTubePlayer: YouTubePlayer
    
    // MARK: - Other Properties
    var cancellableBag = Set<AnyCancellable>()
    private var timerCancellable: Cancellable?
    // リピートタスクの管理用プロパティ
    private var repeatTask: Task<Void, Never>?
    
    // 翻訳リクエストで処理する翻訳可能な字幕の最大合計要素数
    private let maxTotalSubtitlesPerRequest: Int = 30
    // 翻訳対象の字幕要素をさらに分割するチャンクサイズ
    private var translatedSubtitleChunkSize: Int { maxTotalSubtitlesPerRequest / 2 }
    // 全字幕のうち、全ての翻訳対象の字幕が分割/格納される
    var allChunkedSubtitles: [[SubtitleModel.SubtitleDetailModel]] {
        subtitleDetails.chunked(into: maxTotalSubtitlesPerRequest)
    }
    // 全字幕のうち、選択した翻訳対象の字幕が分割/格納される
    var selectedChunkedSubtitles: [[SubtitleModel.SubtitleDetailModel]] {
        selectedTranslatedSubtitles.chunked(into: maxTotalSubtitlesPerRequest)
    }
    
    // MARK: - Deinitializer
    init(apiService: APIServiceType, youTubePlayer: YouTubePlayer) {
        self.apiService = apiService
        self.youTubePlayer = youTubePlayer
        
        // 各Publisherをセットアップ
        setupBindings()
    }
    
    // MARK: - Apply API Event
    func apply(event: ApiEvent) {
        isLoading = true // ローディング開始
        loadingText = "" // ローディング中の文言
        youTubePlayer.pause() // 動画停止
        switch event {
        case .getSubtitles(let videoId):
            getSubtitles(videoId: videoId)
        case .getSavedSubtitles(let videoId):
            getSavedSubtitles(videoId: videoId)
        case .translate(let pendingTranslatedSubtitles):
            loadingText = "翻訳中です。\nしばらくお待ちください。"
            isShowSheet = false
            translate(pendingTranslatedSubtitles: pendingTranslatedSubtitles)
        case .store(let videoInfo):
            store(videoInfo: videoInfo)
        case .update(let id):
            update(id: id)
        }
    }
    
    // MARK: - Setup Bindings
    private func setupBindings() {
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
        
        // 押下された字幕を発行する（append)
        appendSubtitleButtonPressed
            .receive(on: RunLoop.main)
            .sink { [weak self] subtitleDetail in
                guard let self = self else { return }
                // 配列に格納
                self.selectedTranslatedSubtitles.append(subtitleDetail)
                // idが低い順にsort
                self.selectedTranslatedSubtitles.sort(by: { $0.id < $1.id })
            }
            .store(in: &cancellableBag)
        
        // 押下された字幕を発行する（remove)
        removeSubtitleButtonPressed
            .receive(on: RunLoop.main)
            .sink { [weak self] subtitleDetail in
                guard let self = self else { return }
                // 配列から除外
                self.selectedTranslatedSubtitles.removeAll { $0.id == subtitleDetail.id }
            }
            .store(in: &cancellableBag)
        
        // 現在編集中の字幕＆編集された英語/日本語字幕を発行する
        editSubtitleButtonPressed
            .receive(on: RunLoop.main)
            .sink { [weak self] editedEnSubtitle, editedJaSubtitle, memo in
                guard let self = self,
                      let currentSubtitle = self.currentlyEditedSubtitleDetail,
                      let index = self.subtitleDetails.firstIndex(where: { $0.id == currentSubtitle.id }) else {
                    return
                }
                // 編集した英語/日本語字幕を更新
                var updatedSubtitle = currentSubtitle
                updatedSubtitle.enSubtitle = editedEnSubtitle
                updatedSubtitle.jaSubtitle = editedJaSubtitle
                updatedSubtitle.memo = memo
                
                // @Publishedにより変更を発行
                self.subtitleDetails[index] = updatedSubtitle
            }
            .store(in: &cancellableBag)
        
        // HTTP通信時のエラーを発行する
        myAppErrorSubject
            .sink(receiveValue: { [weak self] (error) in
                guard let self = self else { return }
                self.isLoading = false
                self.isSuccess = false
                self.successStatus = nil
                self.isShowError = true
                self.myAppErrorMsg = error.localizedDescription
            })
            .store(in: &cancellableBag)
    }
    
    // MARK: - Deinitializer
    deinit {
        // API通信中に遷移元画面に戻った場合のための処理
        isLoading = false
        isSuccess = false
        successStatus = nil
        isShowError = false
        
        cancellableBag.removeAll()
        stopTimer()
        stopRepeat()
    }
    
    // 翻訳アイコンが押下されているかどうか判定
    func contains(element: SubtitleModel.SubtitleDetailModel) -> Bool {
        return selectedTranslatedSubtitles.contains(where: { $0.subtitleId == element.subtitleId })
    }
    
    // 翻訳アイコンを全選択/全未選択状態に応じて、翻訳する字幕を格納する配列を操作
    func appendOrRemoveAllSubtitles() {
        if isTranslateIconSelectedAll {
            // 配列に全ての字幕を代入
            selectedTranslatedSubtitles = subtitleDetails
        } else {
            // 翻訳する字幕を全て排除
            selectedTranslatedSubtitles.removeAll()
        }
    }
    
    // 翻訳リクエストで処理する翻訳可能な字幕の最大合計要素数で分割
    func chunkSubtitles(subtitles: [SubtitleModel.SubtitleDetailModel]) -> [[SubtitleModel.SubtitleDetailModel]]{
        subtitles.chunked(into: maxTotalSubtitlesPerRequest)
    }
}

// MARK: - Playback Controls
extension StudyViewModel {
    // 共通のシーク処理
    private func seek(to measurement: Measurement<UnitDuration>) {
        youTubePlayer.seek(to: measurement, allowSeekAhead: true)
    }
    
    // ハイライトされる字幕のindexを更新
    func updateCurrentSubtitleIndex(for currentTime: Double) {
        // 字幕同期が無効中、字幕がない場合はreturn
        guard !isSubtitleSync, subtitleDetails.count >= 1 else { return }
        
        for i in 0..<subtitleDetails.count - 1 {
            if currentTime >= subtitleDetails[i].start && currentTime < subtitleDetails[i + 1].start {
                currentSubtitleIndex = i
                break
            } else {
                currentSubtitleIndex = nil
            }
        }
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
    func rewind() { seek(by: -3.0) }
    
    // 3秒早送り 秒数は固定
    func fastForward() { seek(by: 3.0) }
    
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

// MARK: - API Request
extension StudyViewModel {
    // リクエスト
    private func handleRequest<T, R>(request: R) -> AnyPublisher<T, Never> where R: CommonHttpRouter, T: Decodable {
        apiService.request(with: request)
            .receive(on: RunLoop.main)
            .catch { [weak self] error -> Empty<Decodable, Never> in
                guard let self = self else { return .init() }
                self.myAppErrorSubject.send(error)
                return .init()
            }
            .flatMap { value -> AnyPublisher<T, Never> in
                guard let castedValue = value as? T else { return Empty().eraseToAnyPublisher() }
                return Just(castedValue).eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    // 字幕取得
    private func getSubtitles(videoId: String) -> Void {
        // 字幕取得処理リクエスト組み立て
        let getSubtitlesRequest = GetSubtitlesRequest(videoId: videoId)
        // リクエスト
        handleRequest(request: getSubtitlesRequest)
            .sink(receiveValue: { [weak self] (value: SubtitleModel) in
                guard let self = self else { return }
                // idが小さい順にsort
                self.subtitleDetails = value.subtitles.sorted(by: { $0.id < $1.id })
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
        handleRequest(request: getSavedSubtitlesRequest)
            .sink(receiveValue: { [weak self] (value: SubtitleModel) in
                guard let self = self else { return }
                // idが小さい順にsort
                self.subtitleDetails = value.subtitles.sorted(by: { $0.id < $1.id })
                self.isLoading = false
                self.isSuccess = true
            })
            .store(in: &cancellableBag)
    }
    
    // 翻訳
    private func translate(pendingTranslatedSubtitles: [SubtitleModel.SubtitleDetailModel]) -> Void {
        // 翻訳対象の字幕要素を格納する配列をさらに分割
        let chunkedSubtitles = pendingTranslatedSubtitles.chunked(into: translatedSubtitleChunkSize)
        
        // 分割の数分、翻訳リクエストを行う
        let publishers = chunkedSubtitles.map { subtitlesChunk -> AnyPublisher<OpenAIResponseModel, Never> in
            var content: String = ""
            subtitlesChunk.forEach {
                content += "''(ID:\($0.subtitleId)) \($0.enSubtitle)''\n"
            }
            // 翻訳する全ての字幕を格納する配列の要素数
            let totalSubtitlesCount: Int = pendingTranslatedSubtitles.count
            let translateRequest = TranslateRequest(content: content, totalSubtitlesCount: totalSubtitlesCount)
            return handleRequest(request: translateRequest)
        }
        
        // 拡張クラスとして作成したZipを使用
        Publishers.ZipMany(upstreams: publishers)
            .sink(receiveValue: { [weak self] (openAIResponseModelArr: [OpenAIResponseModel]) -> Void in
                guard let self = self else { return }
                // 新しい配列を作成して更新
                var updatedSubtitleDetails = subtitleDetails
                
                for openAIResponseModel in openAIResponseModelArr {
                    // answerは[id: 日本語字幕]の形式
                    let answer: [String: String] = openAIResponseModel.answer
                    // answerに含まれる字幕IDに対応する日本語字幕を、updatedSubtitleDetails配列の該当する要素に上書き
                    for (idString, jaSubtitle) in answer {
                        if let id = Int(idString) {
                            if let index = updatedSubtitleDetails.firstIndex(where: { $0.subtitleId == id }) {
                                updatedSubtitleDetails[index].jaSubtitle = jaSubtitle
                            }
                        }
                    }
                }
                // 更新された配列を再代入して、変更を発行
                subtitleDetails = updatedSubtitleDetails
                
                self.isLoading = false
                self.isSuccess = true
                self.successStatus = .subtitlesTranslated
            })
            .store(in: &cancellableBag)
    }
    
    // DBに動画＆字幕情報の保存
    private func store(videoInfo: VideoListRow.VideoInfo) {
        // 動画のID
        let videoId = videoInfo.videoId
        // 動画のタイトル
        let title = videoInfo.title
        // 動画のサムネイル
        let thumbnailUrl = videoInfo.thumbnailURL
        
        // リクエスト組み立て
        let storeSubtitlesRequestModel = StoreSubtitlesRequestModel(videoId: videoId, title: title, thumbnailUrl: thumbnailUrl, subtitles: subtitleDetails)
        let storeSubtitlesRequest = StoreSubtitlesRequest(model: storeSubtitlesRequestModel)
        
        // リクエスト
        handleRequest(request: storeSubtitlesRequest)
            .sink(receiveValue: { [weak self] (_: EmptyModel) in
                guard let self = self else { return }
                self.isLoading = false
                self.isSuccess = true
                self.successStatus = .dataSaved
            })
            .store(in: &cancellableBag)
    }
    
    // DB更新
    private func update(id: Int) {
        // リクエスト組み立て
        let subtitleModel = SubtitleModel(subtitles: subtitleDetails)
        let updateSubtitlesRequest = UpdateSubtitlesRequest(id: id, model: subtitleModel)
        // リクエスト
        handleRequest(request: updateSubtitlesRequest)
            .sink(receiveValue: { [weak self] (_: EmptyModel) in
                guard let self = self else { return }
                self.isLoading = false
                self.isSuccess = true
                self.successStatus = .dataSaved
            })
            .store(in: &cancellableBag)
    }
}

extension Publishers {
    struct ZipMany<Element, F: Error>: Publisher {
        
        typealias Output = [Element]
        typealias Failure = F
        
        private let upstreams: [AnyPublisher<Element, F>]
        
        init(upstreams: [AnyPublisher<Element, F>]) {
            self.upstreams = upstreams
        }
        
        func receive<S: Subscriber>(subscriber: S) where Self.Failure == S.Failure, Self.Output == S.Input {
            let initial = Just<[Element]>([])
                .setFailureType(to: F.self)
                .eraseToAnyPublisher()
            
            let zipped = upstreams.reduce(into: initial) { result, upstream in
                result = result.zip(upstream) { elements, element in
                    elements + [element]
                }
                .eraseToAnyPublisher()
            }
            
            zipped.subscribe(subscriber)
        }
    }
}
