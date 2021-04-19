//
//  FeedUIComposer.swift
//  EssentialFeediOS
//
//  Created by Riccardo Rossi - Home on 13/04/21.
//

import UIKit
import EssentialFeed

public final class FeedUIComposer {
    private init() {}
    
    public static func feedComposedWith(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) -> FeedViewController {
        let presentationAdapter = FeedLoaderPresentationAdapter()
        let refreshController = FeedRefreshController(loadFeed: presentationAdapter.loadFeed)
        let feedController = FeedViewController(refreshController: refreshController)
        let presenter = FeedPresenter(
            feedView: FeedViewAdapter(feedController: feedController, loader: imageLoader),
            loadingView: WeakRefVirtualProxy(refreshController))
        
        presentationAdapter.loader = feedLoader
        presentationAdapter.presenter = presenter
        
        return feedController
    }
}

private final class WeakRefVirtualProxy<T: AnyObject> {
    private weak var object: T?
    
    init(_ object: T) {
        self.object = object
    }
}

extension WeakRefVirtualProxy: FeedLoadingView where T: FeedLoadingView {
    func display(_ viewModel: FeedLoadingViewModel) {
        object?.display(viewModel)
    }
}

private final class FeedLoaderPresentationAdapter {
    var loader: FeedLoader?
    var presenter: FeedPresenter?
    
    func loadFeed() {
        presenter?.didStartLoadingFeed()
        loader?.load { [weak presenter] result in
            switch result {
            case let .success(feed):
                presenter?.didFinishLoadingFeed(with: feed)
            case let .failure(error):
                presenter?.didFinishLoadingFeed(with: error)
            }
        }
    }
}

private final class FeedViewAdapter: FeedView {
    private weak var feedController: FeedViewController?
    private let loader: FeedImageDataLoader
    
    init(feedController: FeedViewController, loader: FeedImageDataLoader) {
        self.feedController = feedController
        self.loader = loader
    }
    
    func display(_ viewModel: FeedViewModel) {
        feedController?.tableModel = viewModel.feed.map { model in
            let imageCellViewModel = FeedImageCellViewModel<UIImage>(
                model: model,
                imageLoader: loader,
                imageTransformer: UIImage.init
            )
            return FeedImageCellController(viewModel: imageCellViewModel)
        }
    }
}
