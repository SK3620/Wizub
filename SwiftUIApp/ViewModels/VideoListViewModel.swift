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
        // CardView（動画）タップ時
        case tappedCardView
    }
    
    @Published var isLoading: Bool = false
    @Published var isSuccess: Bool = false
    @Published var isShowError: Bool = false
    @Published var httpErrorMsg: String = ""
    
    @Published var cardViewVideoInfo: [CardView.VideoInfo] = []
    @Published var statusViewModel: StatusViewModel = StatusViewModel(isLoading: false, shouldTransition: false, showErrorMessage: false, alertErrorMessage: "")
    
    func apply(event: Event) {
        switch event {
        case .serach(let inputText):
            getVideos(inputText: inputText)
        case .getSavedVideos:
            getSavedVideos()
        case .deleteSavedVideos(let id):
            deleteSavedVideos(id: id)
        case.checkVideoAlreadySaved(let videoId):
            checkVideoAlreadySaved(videoId: videoId)
        case .tappedCardView:
            print("Tapped")
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
    
    // 検索した動画を取得
    private func getVideos(inputText: String) -> Void {
        // リクエスト組み立て
        let youTubeSearchRequest = YouTubeSearchRequest(query: inputText)
        
        // リクエスト
        apiService.request(with: youTubeSearchRequest)
            .receive(on: RunLoop.main)
            .catch { [weak self] (error) -> Empty<Decodable, Never> in
                // 上流Publisherのエラーをcatch 別のPublisherへエラーを流す
                self?.httpErrorSubject.send(error)
                // 空のPublisherに置き換えストリームを中断
                return .init()
            }
            .sink(receiveValue: { [weak self] value in
                guard let self = self, let youTubeSerachResponse = YouTubeSearchResponseModel.handleResponse(value: value) else { return }
                self.cardViewVideoInfo.append(contentsOf: convertSerachResponse(videos: youTubeSerachResponse.items))
                self.isLoading = false
                self.isSuccess = true
            })
            .store(in: &cancellableBag)
    }
    
    // 保存した動画を取得
    private func getSavedVideos() {
        // リクエスト組み立て
        let getSavedVideosRequest = GetSavedVideosRequest()
        
        // リクエスト
        apiService.request(with: getSavedVideosRequest)
            .receive(on: RunLoop.main)
            .catch { [weak self] (error) -> Empty<Decodable, Never> in
                // 上流Publisherのエラーをcatch 別のPublisherへエラーを流す
                self?.httpErrorSubject.send(error)
                // 空のPublisherに置き換えストリームを中断
                return .init()
            }
            .sink(receiveValue: { [weak self] value in
                guard let self = self, let getSavedVideosResponse = GetSavedVideosResponseModel.handleResponse(value: value) else { return }
                self.cardViewVideoInfo.append(contentsOf: convertGetSavedVideosResponse(videos: getSavedVideosResponse.items))
                self.isLoading = false
                self.isSuccess = true
            })
            .store(in: &cancellableBag)
    }
    
    // 保存した動画を削除
    private func deleteSavedVideos(id: Int) {
        // リクエスト組み立て
        let deleteSavedVideosRequest = DeleteSavedVideosRequest(id: id)
        
        // リクエスト
        apiService.request(with: deleteSavedVideosRequest)
            .receive(on: RunLoop.main)
            .catch { [weak self] (error) -> Empty<Decodable, Never> in
                // 上流Publisherのエラーをcatch 別のPublisherへエラーを流す
                self?.httpErrorSubject.send(error)
                // 空のPublisherに置き換えストリームを中断
                return .init()
            }
            .sink(receiveValue: { [weak self] value in
                guard let self = self, let index = self.cardViewVideoInfo.firstIndex(where: { $0.id == id }) else { return }
                // 要素を配列から削除
                self.cardViewVideoInfo.remove(at: index)
                self.isLoading = false
                self.isSuccess = true
            })
            .store(in: &cancellableBag)
    }
    
    private func convertSerachResponse(videos: [YouTubeSearchResponseModel.Video]) -> [CardView.VideoInfo] {
        return videos.map { video in
            CardView.VideoInfo(
                id: video.id,
                isVideoAlradySaved: video.isVideoAlreadySaved,
                videoId: video.videoId,
                title: video.title,
                thumbnailURL: video.thumbnailUrl
            )
        }
    }
    
    private func convertGetSavedVideosResponse(videos: [GetSavedVideosResponseModel.Video]) -> [CardView.VideoInfo] {
        return videos.map { video in
            CardView.VideoInfo(
                id: video.id,
                isVideoAlradySaved: true, // "videos"には保存済みの動画しか格納されていないため"true"
                videoId: video.videoId,
                title: video.title,
                thumbnailURL: video.thumbnailUrl
            )
        }
    }
    
    // 保存済みの動画かチェック
    private func checkVideoAlreadySaved(videoId: String) {
        // リクエスト組み立て
        let checkVideoAlreadySavedRequest = CheckVideoAlreadySavedRequest(videoId: videoId)
        
        // リクエスト
        apiService.request(with: checkVideoAlreadySavedRequest)
            .receive(on: RunLoop.main)
            .catch { [weak self] (error) -> Empty<Decodable, Never> in
                // 上流Publisherのエラーをcatch 別のPublisherへエラーを流す
                self?.httpErrorSubject.send(error)
                // 空のPublisherに置き換えストリームを中断
                return .init()
            }
            .sink(receiveValue: { [weak self] value in
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
