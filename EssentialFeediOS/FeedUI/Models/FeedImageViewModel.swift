//
//  FeedImageViewModel.swift
//  EssentialFeediOS
//
//  Created by Riccardo Rossi - Home on 17/04/21.
//

import Foundation
import EssentialFeed

final class FeedImageCellViewModel<Image> {
    typealias Observer<T> = (T) -> Void
    
    private var task: FeedImageDataLoaderTask?
    private var model: FeedImage
    private var imageLoader: FeedImageDataLoader
    private var imageTransformer: (Data) -> Image?
    
    init(model: FeedImage, imageLoader: FeedImageDataLoader, imageTransformer: @escaping (Data) -> Image?) {
        self.model = model
        self.imageLoader = imageLoader
        self.imageTransformer = imageTransformer
    }
    
    var isLocationHidden: Bool {
        return model.location == nil
    }
    
    var locationText: String? {
        return model.location
    }
    
    var descriptionText: String? {
        return model.description
    }

    var onImageLoad: Observer<Image>?
    var onImageLoadingStateChange: Observer<Bool>?
    var onShouldRetryImageLoadStateChange: Observer<Bool>?
    
    func loadImage() {
        onImageLoadingStateChange?(true)
        onShouldRetryImageLoadStateChange?(false)
        task = imageLoader.loadImageData(from: model.url) { [weak self] result in
            self?.handle(result)
        }
    }

    func preloadImage() {
        task = imageLoader.loadImageData(from: model.url) { _ in }
    }
    
    func cancelImageLoading() {
        task?.cancel()
    }
    
    private func handle(_ result: Result<Data, Error>) {
        if let image = (try? result.get()).flatMap(self.imageTransformer) {
            self.onImageLoad?(image)
        } else {
            self.onShouldRetryImageLoadStateChange?(true)
        }
        self.onImageLoadingStateChange?(false)
    }
}
