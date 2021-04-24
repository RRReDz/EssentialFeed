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
        let refreshController = FeedRefreshController(delegate: presentationAdapter)
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

private final class FeedLoaderPresentationAdapter: FeedRefreshControllerDelegate {
    var loader: FeedLoader?
    var presenter: FeedPresenter?
    
    func didRequestFeedRefresh() {
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

private final class FeedImagePresentationAdapter<Image, View: FeedImageView>: FeedImageCellControllerDelegate where Image == View.Image {
    private let model: FeedImage
    private let loader: FeedImageDataLoader
    private var task: FeedImageDataLoaderTask?
    
    var presenter: FeedImagePresenter<Image, View>?
    
    init(model: FeedImage, loader: FeedImageDataLoader) {
        self.model = model
        self.loader = loader
    }
    
    func didRequestImage() {
        presenter?.startLoadingImageData(for: model)
        task = loader.loadImageData(from: model.url) { [weak presenter] result in
            switch result {
            case let .success(imageData):
                presenter?.endLoadingImageData(with: imageData)
            case let .failure(error):
                presenter?.endLoadingImageData(with: error)
            }
        }
    }
    
    func didCancelImageRequest() {
        task?.cancel()
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
            let imageCellPresenter = FeedImagePresenter<UIImage, WeakRefVirtualProxy<FeedImageCellController>>(
                imageLoader: loader,
                imageTransformer: UIImage.init,
                imageView: WeakRefVirtualProxy(feedImageController),
                imageStaticDataView: WeakRefVirtualProxy(feedImageController),
                loadingView: WeakRefVirtualProxy(feedImageController),
                retryLoadingView: WeakRefVirtualProxy(feedImageController)
            )
            presentationAdapter.presenter = imageCellPresenter
            return feedImageController
        }
    }
}

extension WeakRefVirtualProxy: FeedImageView where T: FeedImageView, T.Image == UIImage {
    func display(image: UIImage) {
        object?.display(image: image)
    }
}

extension WeakRefVirtualProxy: FeedImageLoadingView where T: FeedImageLoadingView {
    func display(isLoading: Bool) {
        object?.display(isLoading: isLoading)
    }
}

extension WeakRefVirtualProxy: FeedImageRetryLoadingView where T: FeedImageRetryLoadingView {
    func display(retryImageLoading: Bool) {
        object?.display(retryImageLoading: retryImageLoading)
    }
}

extension WeakRefVirtualProxy: FeedImageStaticDataView where T: FeedImageStaticDataView {
    func display(_ viewModel: FeedImageStaticDataViewModel) {
        object?.display(viewModel)
    }
}
