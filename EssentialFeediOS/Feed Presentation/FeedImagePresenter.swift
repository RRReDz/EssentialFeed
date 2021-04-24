//
//  FeedImagePresenter.swift
//  EssentialFeediOS
//
//  Created by Riccardo Rossi - Home on 20/04/21.
//

import Foundation
import EssentialFeed

protocol FeedImageView {
    associatedtype Image
    func display(image: Image)
}

struct FeedImageStaticDataViewModel {
    let location: String?
    let description: String?
}

protocol FeedImageStaticDataView {
    func display(_ viewModel: FeedImageStaticDataViewModel)
}

protocol FeedImageLoadingView {
    func display(isLoading: Bool)
}

protocol FeedImageRetryLoadingView {
    func display(retryImageLoading: Bool)
}

final class FeedImagePresenter<Image, ImageView: FeedImageView> where Image == ImageView.Image {
    private var task: FeedImageDataLoaderTask?
    private var model: FeedImage
    private var imageLoader: FeedImageDataLoader
    private var imageTransformer: (Data) -> Image?
    
    var imageView: ImageView?
    var imageStaticDataView: FeedImageStaticDataView?
    var loadingView: FeedImageLoadingView?
    var retryLoadingView: FeedImageRetryLoadingView?
    
    init(model: FeedImage, imageLoader: FeedImageDataLoader, imageTransformer: @escaping (Data) -> Image?) {
        self.model = model
        self.imageLoader = imageLoader
        self.imageTransformer = imageTransformer
    }
}

extension FeedImagePresenter: FeedImageCellControllerDelegate {
    func didRequestImage() {
        imageStaticDataView?.display(
            FeedImageStaticDataViewModel(
                location: model.location,
                description: model.description))
        
        loadingView?.display(isLoading: true)
        retryLoadingView?.display(retryImageLoading: false)
        task = imageLoader.loadImageData(from: model.url) { [weak self] result in
            self?.handle(result)
        }
    }
    
    private func handle(_ result: Result<Data, Error>) {
        if let image = (try? result.get()).flatMap(self.imageTransformer) {
            imageView?.display(image: image)
        } else {
            retryLoadingView?.display(retryImageLoading: true)
        }
        loadingView?.display(isLoading: false)
    }
    
    func didCancelImageRequest() {
        task?.cancel()
    }
}
