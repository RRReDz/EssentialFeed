//
//  FeedViewAdapter.swift
//  EssentialFeediOS
//
//  Created by Riccardo Rossi - Home on 02/05/21.
//

import EssentialFeed
import UIKit

final class FeedViewAdapter: FeedView {
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
                imageView: WeakRefVirtualProxy(feedImageController),
                imageTransformer: UIImage.init
            )
            presentationAdapter.presenter = imageCellPresenter
            return feedImageController
        }
    }
}
