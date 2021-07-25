//
//  FeedUIComposer.swift
//  EssentialFeediOS
//
//  Created by Riccardo Rossi - Home on 13/04/21.
//

import UIKit
import EssentialFeed
import EssentialFeediOS

public final class FeedUIComposer {
    private init() {}
    
    public static func feedComposedWith(feedLoader: FeedLoader.Publisher, imageLoader: @escaping (URL) -> FeedImageDataLoader.Publisher) -> FeedViewController {
        let presentationAdapter = FeedLoaderPresentationAdapter(loader: feedLoader.dispatchOnMainQueue())
        let feedController = FeedViewController.makeWith(delegate: presentationAdapter)
        
        presentationAdapter.presenter = FeedPresenter(
            feedView: FeedViewAdapter(
                feedController: feedController,
                loader: { imageLoader($0).dispatchOnMainQueue() }),
            loadingView: WeakRefVirtualProxy(feedController),
            errorView: WeakRefVirtualProxy(feedController))
        
        return feedController
    }
}

private extension FeedViewController {
    static func makeWith(delegate: FeedControllerDelegate) -> FeedViewController {
        let bundle = Bundle(for: FeedViewController.self)
        let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
        let feedController = storyboard.instantiateInitialViewController(creator: { coder in
            return FeedViewController(coder: coder, delegate: delegate)
        })!
        feedController.title = FeedPresenter.title
        return feedController
    }
}

