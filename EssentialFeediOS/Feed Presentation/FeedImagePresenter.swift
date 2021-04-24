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
    func display(_ viewModel: FeedImageViewModel<Image>)
}

struct FeedImageViewModel<Image> {
    let location: String?
    let description: String?
    let image: Image?
    let isLoading: Bool
    let retryLoading: Bool
}

final class FeedImagePresenter<Image, ImageView: FeedImageView> where Image == ImageView.Image {
    private let imageLoader: FeedImageDataLoader
    private let imageTransformer: (Data) -> Image?
    private let imageView: ImageView
    
    init(
        imageLoader: FeedImageDataLoader,
        imageView: ImageView,
        imageTransformer: @escaping (Data) -> Image?
    ) {
        self.imageLoader = imageLoader
        self.imageView = imageView
        self.imageTransformer = imageTransformer
    }
    
    func startLoadingImageData(for model: FeedImage) {
        imageView.display(
            FeedImageViewModel(
                location: model.location,
                description: model.description,
                image: nil,
                isLoading: true,
                retryLoading: false))
    }
    
    private struct InvalidImageDataError: Error {}
    
    func endLoadingImageData(with imageData: Data, for model: FeedImage) {
        guard let image = imageTransformer(imageData) else {
            return endLoadingImageData(with: InvalidImageDataError(), for: model)
        }
        imageView.display(
            FeedImageViewModel(
                location: model.location,
                description: model.description,
                image: image,
                isLoading: false,
                retryLoading: false))
    }
    
    func endLoadingImageData(with error: Error, for model: FeedImage) {
        imageView.display(
            FeedImageViewModel(
                location: model.location,
                description: model.description,
                image: nil,
                isLoading: false,
                retryLoading: true))
    }
}
