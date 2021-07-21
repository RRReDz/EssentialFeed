//
//  FeedLoaderPresentationAdapter.swift
//  EssentialFeediOS
//
//  Created by Riccardo Rossi - Home on 02/05/21.
//

import Combine
import EssentialFeed
import EssentialFeediOS

final class FeedLoaderPresentationAdapter: FeedControllerDelegate {
    private let loader: FeedLoader.Publisher
    private var cancellable: Cancellable?
    var presenter: FeedPresenter?
    
    init(loader: FeedLoader.Publisher) {
        self.loader = loader
    }
    
    func didRequestFeedRefresh() {
        presenter?.didStartLoadingFeed()
        
        cancellable = loader.sink(
            receiveCompletion: { [weak presenter] completion in
                switch completion {
                case .finished: break
                case let .failure(error):
                    presenter?.didFinishLoadingFeed(with: error)
                }
            },
            receiveValue: { [weak presenter] feed in
                presenter?.didFinishLoadingFeed(with: feed)
            }
        )
    }
}
