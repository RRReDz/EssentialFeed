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
