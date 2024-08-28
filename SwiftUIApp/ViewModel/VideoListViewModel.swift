//
//  VideoListViewModel.swift
//  SwiftUIApp
//
//  Created by 鈴木 健太 on 2024/08/20.
//

import Foundation
import Combine

class VideoListViewModel: ObservableObject {
    
    enum Inputs {
        // 検索時
        case serach(text: String)
        // CardView（動画）タップ時
        case tappedCardView
    }
    
    private let apiService: APIServiceType
    
    private var cancellableBag = Set<AnyCancellable>()
    
    @Published var cardViewVideoInfo: [CardView.VideoInfo] = []
    
    @Published var statusViewModel: StatusViewModel = StatusViewModel(isLoading: false, shouldTransition: false, showErrorMessage: false, alertErrorMessage: "")
    
    var shouldLoadMore: Bool = false
    private var nextPageToken: String?

    func apply(inputs: Inputs) {
        switch inputs {
        case .serach(let inputText):
            getVideos(inputText: inputText)
        case .tappedCardView:
            print("Tapped")
        }
    }
    
    init(apiService: APIServiceType) {
        self.apiService = apiService
    }
}

extension VideoListViewModel {
    
    private func getVideos(inputText: String) -> Void {
        
        // リクエスト組み立て
        var youTubeSearchRequest: YouTubeSearchRequest
        if shouldLoadMore {
            // 追加で動画を読み込む
            youTubeSearchRequest = YouTubeSearchRequest(query: inputText, nextPageToken: nextPageToken)
        } else {
            youTubeSearchRequest = YouTubeSearchRequest(query: inputText)
        }
        
        // リクエスト
        apiService.request(with: youTubeSearchRequest)
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { [weak self] completion in
                guard let self = self else { return }
                switch completion {
                case .finished:
                    // ローディングアイコン表示終了
                    self.statusViewModel = StatusViewModel(isLoading: false)
                    self.shouldLoadMore = true
                case .failure(let error):
                    // エラーアラート表示
                    self.statusViewModel = StatusViewModel(showErrorMessage: true, alertErrorMessage: error.localizedDescription)
                    self.shouldLoadMore = true
                }
            }, receiveValue: { [weak self] value in
                guard let self = self, let youTubeSerachResponse = YouTubeSearchResponseModel.handleResponse(value: value) else { return }
                self.cardViewVideoInfo.append(contentsOf: convertSerachResponses(videos: youTubeSerachResponse.items))
                self.nextPageToken = youTubeSerachResponse.nextPageToken
            })
            .store(in: &cancellableBag)
    }
    
    private func convertSerachResponses(videos: [YouTubeSearchResponseModel.Video]) -> [CardView.VideoInfo] {
        return videos.map { video in
            CardView.VideoInfo(
                videoId: video.id.videoId,
                title: video.snippet.title,
                thumbnailURL: video.snippet.thumbnails.default.url
            )
        }
    }
}
