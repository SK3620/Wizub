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
        // CardViewタップ時
        case tappedCardView
    }
    
    private let apiService: APIServiceType
    
    private var cancellableBag = Set<AnyCancellable>()
    
    @Published private(set) var cardViewVideoInfo: [CardView.VideoInfo] = []
    
    @Published var statusViewModel: StatusViewModel = StatusViewModel(isLoading: false, shouldTransition: false, showErrorMessage: false, alertErrorMessage: "")

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
        let youTubeSearchRequest = YouTubeSearchRequest(query: inputText)
        
        // リクエスト
        apiService.request(with: youTubeSearchRequest)
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { [weak self] completion in
                guard let self = self else { return }
                switch completion {
                case .finished:
                    // ローディングアイコン表示終了
                    self.statusViewModel.isLoading = false
                case .failure(let error):
                    // エラーアラート表示
                    self.statusViewModel = StatusViewModel(isLoading: false, shouldTransition: false, showErrorMessage: true, alertErrorMessage: error.localizedDescription)
                }
            }, receiveValue: { [weak self] value in
                guard let self = self, let youTubeSerachResponse = YouTubeSearchResponse.handleResponse(value: value) else { return }
                self.cardViewVideoInfo = convertSerachResponses(videos: youTubeSerachResponse.items)
            })
            .store(in: &cancellableBag)
    }
    
    private func convertSerachResponses(videos: [YouTubeSearchResponse.Video]) -> [CardView.VideoInfo] {
        return videos.map { video in
            CardView.VideoInfo(
                videoId: video.id.videoId,
                title: video.snippet.title,
                thumbnailURL: video.snippet.thumbnails.default.url
            )
        }
    }
}
