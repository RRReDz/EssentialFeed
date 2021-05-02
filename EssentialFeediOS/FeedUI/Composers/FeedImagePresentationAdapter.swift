//
//  FeedImagePresentationAdapter.swift
//  EssentialFeediOS
//
//  Created by Riccardo Rossi - Home on 02/05/21.
//

import EssentialFeed

final class FeedImagePresentationAdapter<Image, View: FeedImageView>: FeedImageCellControllerDelegate where Image == View.Image {
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
        task = loader.loadImageData(from: model.url) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .success(imageData):
                self.presenter?.endLoadingImageData(with: imageData, for: self.model)
            case let .failure(error):
                self.presenter?.endLoadingImageData(with: error, for: self.model)
            }
        }
    }
    
    func didCancelImageRequest() {
        task?.cancel()
    }
}
