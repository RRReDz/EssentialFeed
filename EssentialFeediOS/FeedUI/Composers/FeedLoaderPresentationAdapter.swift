//
//  FeedLoaderPresentationAdapter.swift
//  EssentialFeediOS
//
//  Created by Riccardo Rossi - Home on 02/05/21.
//

import EssentialFeed

final class FeedLoaderPresentationAdapter: FeedControllerDelegate {
    private let loader: FeedLoader
    var presenter: FeedPresenter?
    
    init(loader: FeedLoader) {
        self.loader = loader
    }
    
    func didRequestFeedRefresh() {
        presenter?.didStartLoadingFeed()
        loader.load { [weak presenter] result in
            switch result {
            case let .success(feed):
                presenter?.didFinishLoadingFeed(with: feed)
            case let .failure(error):
                presenter?.didFinishLoadingFeed(with: error)
            }
        }
    }
}
