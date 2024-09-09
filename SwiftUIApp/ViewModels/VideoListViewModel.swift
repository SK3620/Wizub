//
//  VideoListViewModel.swift
//  SwiftUIApp
//
//  Created by 鈴木 健太 on 2024/08/20.
//

import Foundation
import Combine

class VideoListViewModel: ObservableObject {
    
    enum Event {
        // 検索した動画を取得
        case serach(text: String)
        // 保存した動画を取得
        case getSavedVideos
        // 保存した動画を削除
        case deleteSavedVideos(id: Int)
        // 保存済みの動画かチェック
        case checkVideoAlreadySaved(videoId: String)
    }
    
    // MARK: - Outputs
    @Published var isLoading: Bool = false
    @Published var isSuccess: Bool = false
    @Published var isShowError: Bool = false
    @Published var httpErrorMsg: String = ""
    
    // 検索値 初期値あり
    @Published var text = "How to speak English"
    // 初期値による検索は一度のみ
    @Published var hasPerformedInitialSearch = false
    // 押下された動画を保持する
    @Published var tappedVideoInfo: (VideoListRow.VideoInfo)?
    // 取得した動画情報を配列で格納
    @Published var cardViewVideoInfo: [VideoListRow.VideoInfo] = []
    
    func apply(event: Event) {
        switch event {
        case .serach(let inputText):
            isLoading = true
            getVideos(inputText: inputText)
        case .getSavedVideos:
            // 配列を空にしてリセット
            cardViewVideoInfo = []
            isLoading = true
            getSavedVideos()
        case .deleteSavedVideos(let id):
            deleteSavedVideos(id: id)
        case .checkVideoAlreadySaved(let videoId):
            checkVideoAlreadySaved(videoId: videoId)
        }
    }
    
    private let apiService: APIServiceType
    private var cancellableBag = Set<AnyCancellable>()
    private let httpErrorSubject = PassthroughSubject<HttpError, Never>()
    
    init(apiService: APIServiceType) {
        self.apiService = apiService
        
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
}

extension VideoListViewModel {
    
    // リクエスト
    private func handleRequest<T, R>(request: R) -> AnyPublisher<T, Never> where R: CommonHttpRouter, T: Decodable {
        apiService.request(with: request)
            .receive(on: RunLoop.main)
            .catch { [weak self] error -> Empty<Decodable, Never> in
                guard let self = self else { return .init() }
                self.httpErrorSubject.send(error)
                return .init()
            }
            .flatMap { value -> AnyPublisher<T, Never> in
                guard let castedValue = value as? T else { return Empty().eraseToAnyPublisher() }
                return Just(castedValue).eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    private func convertResponse<T>(videos: [T]) -> [VideoListRow.VideoInfo] where T: VideoProtocol {
        return videos.map { video in
            VideoListRow.VideoInfo(
                id: video.id,
                isVideoAlradySaved: video.isVideoAlreadySaved,
                videoId: video.videoId,
                title: video.title,
                thumbnailURL: video.thumbnailUrl
            )
        }
    }
    
    // 動画検索
    private func getVideos(inputText: String) -> Void {
        // リクエスト組み立て
        let youTubeSearchRequest = YouTubeSearchRequest(query: inputText)
        // リクエスト
        handleRequest(request: youTubeSearchRequest)
            .sink(receiveValue: { [weak self] (value: GetVideosResponseModel) in
                guard let self = self else { return }
                self.isLoading = false
                self.isSuccess = true
                self.cardViewVideoInfo.append(contentsOf: self.convertResponse(videos: value.items))
            })
            .store(in: &cancellableBag)
    }
    
    // 保存した動画を取得
    private func getSavedVideos() {
        // リクエスト組み立て
        let getSavedVideosRequest = GetSavedVideosRequest()
        // リクエスト
        handleRequest(request: getSavedVideosRequest)
            .sink(receiveValue: { [weak self] (value: GetVideosResponseModel) in
                guard let self = self else { return }
                self.isLoading = false
                self.isSuccess = true
                self.cardViewVideoInfo.append(contentsOf: self.convertResponse(videos: value.items))
            })
            .store(in: &cancellableBag)
    }
    
    // 保存した動画を削除
    private func deleteSavedVideos(id: Int) {
        // リクエスト組み立て
        let deleteSavedVideosRequest = DeleteSavedVideosRequest(id: id)
        // リクエスト
        handleRequest(request: deleteSavedVideosRequest)
            .sink(receiveValue: { [weak self] (_: EmptyModel) in
                guard let self = self, let index = self.cardViewVideoInfo.firstIndex(where: { $0.id == id }) else { return }
                // 要素を配列から削除
                self.cardViewVideoInfo.remove(at: index)
                self.isLoading = false
                self.isSuccess = true
            })
            .store(in: &cancellableBag)
    }
    
    // 保存済みの動画かチェック
    private func checkVideoAlreadySaved(videoId: String) {
        // リクエスト組み立て
        let checkVideoAlreadySavedRequest = CheckVideoAlreadySavedRequest(videoId: videoId)
        // リクエスト
        handleRequest(request: checkVideoAlreadySavedRequest)
            .sink(receiveValue: { [weak self] (value: CheckVideoAlreadySavedResponseModel) in
                guard let self = self, let checkVideoAlreadySavedResponse = CheckVideoAlreadySavedResponseModel.handleResponse(value: value) else { return }
                let isVideoAlreadySaved = checkVideoAlreadySavedResponse.isVideoAlreadySaved
                
                // 新しい配列を作成して更新
                var updatedCardViewViewInfo = cardViewVideoInfo
                
                // 動画が保存済みの場合、プロパティ更新
                if isVideoAlreadySaved {
                    if let index = self.cardViewVideoInfo.firstIndex(where: { $0.videoId == videoId }) {
                        updatedCardViewViewInfo[index].id = checkVideoAlreadySavedResponse.id
                        updatedCardViewViewInfo[index].isVideoAlradySaved = isVideoAlreadySaved
                    }
                }
                
                // 更新された配列を再代入して、変更を発行
                cardViewVideoInfo = updatedCardViewViewInfo
                self.isLoading = false
                self.isSuccess = true
            })
            .store(in: &cancellableBag)
    }
}
