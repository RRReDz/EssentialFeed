//
//  FeedImagePresenter.swift
//  EssentialFeed
//
//  Created by Riccardo Rossi - Home on 30/05/21.
//

import Foundation

public struct FeedImageViewModel<Image> {
    public let location: String?
    public let description: String?
    public let image: Image?
    public let isLoading: Bool
    public let retryLoading: Bool
}

public protocol FeedImageView {
    associatedtype Image
    func display(_ viewModel: FeedImageViewModel<Image>)
}

public final class FeedImagePresenter<Image, ImageView: FeedImageView> where Image == ImageView.Image {
    private let imageView: ImageView
    private let imageTransformer: (Data) -> Image?
    
    public init(imageView: ImageView, imageTransformer: @escaping (Data) -> Image?) {
        self.imageView = imageView
        self.imageTransformer = imageTransformer
    }
    
    public func startLoadingImageData(for model: FeedImage) {
        imageView.display(
            FeedImageViewModel(
                location: model.location,
                description: model.description,
                image: nil,
                isLoading: true,
                retryLoading: false))
    }
    
    private struct InvalidImageDataError: Error {}
    
    public func endLoadingImageData(with imageData: Data, for model: FeedImage) {
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
    
    public func endLoadingImageData(with error: Error, for model: FeedImage) {
        imageView.display(
            FeedImageViewModel(
                location: model.location,
                description: model.description,
                image: nil,
                isLoading: false,
                retryLoading: true))
    }
}
