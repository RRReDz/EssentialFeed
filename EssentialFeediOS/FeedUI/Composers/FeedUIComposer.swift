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
        let presenter = FeedPresenter(feedLoader: feedLoader)
        
        let refreshController = FeedRefreshController(presenter: presenter)
        
        let feedController = FeedViewController(refreshController: refreshController)
        presenter.loadingView = WeakRefVirtualProxy(refreshController)
        presenter.feedView = FeedViewAdapter(feedController: feedController, loader: imageLoader)
        
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
    func display(isLoading: Bool) {
        object?.display(isLoading: isLoading)
    }
}

private final class FeedViewAdapter: FeedView {
    private weak var feedController: FeedViewController?
    private let loader: FeedImageDataLoader
    
    init(feedController: FeedViewController, loader: FeedImageDataLoader) {
        self.feedController = feedController
        self.loader = loader
    }
    
    func display(feed: [FeedImage]) {
        feedController?.tableModel = feed.map { model in
            let imageCellViewModel = FeedImageCellViewModel<UIImage>(
                model: model,
                imageLoader: loader,
                imageTransformer: UIImage.init
            )
            return FeedImageCellController(viewModel: imageCellViewModel)
        }
    }
}
