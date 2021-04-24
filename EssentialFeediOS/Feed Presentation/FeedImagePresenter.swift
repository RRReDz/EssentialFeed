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
    private let imageLoader: FeedImageDataLoader
    private let imageTransformer: (Data) -> Image?
    private let imageView: ImageView
    private let imageStaticDataView: FeedImageStaticDataView
    private let loadingView: FeedImageLoadingView
    private let retryLoadingView: FeedImageRetryLoadingView
    
    init(
        imageLoader: FeedImageDataLoader,
        imageTransformer: @escaping (Data) -> Image?,
        imageView: ImageView,
        imageStaticDataView: FeedImageStaticDataView,
        loadingView: FeedImageLoadingView,
        retryLoadingView: FeedImageRetryLoadingView
    ) {
        self.imageLoader = imageLoader
        self.imageTransformer = imageTransformer
        self.imageView = imageView
        self.imageStaticDataView = imageStaticDataView
        self.loadingView = loadingView
        self.retryLoadingView = retryLoadingView
    }
    
    func startLoadingImageData(for model: FeedImage) {
        imageStaticDataView.display(
            FeedImageStaticDataViewModel(
                location: model.location,
                description: model.description))
        
        loadingView.display(isLoading: true)
        retryLoadingView.display(retryImageLoading: false)
    }
    
    private struct InvalidImageDataError: Error {}
    
    func endLoadingImageData(with imageData: Data) {
        guard let image = imageTransformer(imageData) else {
            return endLoadingImageData(with: InvalidImageDataError())
        }
        imageView.display(image: image)
        loadingView.display(isLoading: false)
    }
    
    func endLoadingImageData(with error: Error) {
        retryLoadingView.display(retryImageLoading: true)
        loadingView.display(isLoading: false)
    }
}
