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
        let presentationAdapter = FeedLoaderPresentationAdapter(
            loader: MainQueueDispatchDecorator(decoratee: feedLoader))
        
        let refreshController = FeedRefreshController(delegate: presentationAdapter)
        
        let feedController = FeedViewController(refreshController: refreshController)
        feedController.title = FeedPresenter.title
        
        presentationAdapter.presenter = FeedPresenter(
            feedView: FeedViewAdapter(
                feedController: feedController,
                loader: MainQueueDispatchDecorator(decoratee: imageLoader)),
            loadingView: WeakRefVirtualProxy(refreshController))
        
        return feedController
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
            let presentationAdapter = FeedImagePresentationAdapter<UIImage, WeakRefVirtualProxy<FeedImageCellController>> (
                model: model, loader: loader
            )
            let feedImageController = FeedImageCellController(delegate: presentationAdapter)
            let imageCellPresenter = FeedImagePresenter(
                imageLoader: loader,
                imageView: WeakRefVirtualProxy(feedImageController),
                imageTransformer: UIImage.init
            )
            presentationAdapter.presenter = imageCellPresenter
            return feedImageController
        }
    }
}
