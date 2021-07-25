//
//  FeedImagePresentationAdapter.swift
//  EssentialFeediOS
//
//  Created by Riccardo Rossi - Home on 02/05/21.
//

import Foundation
import EssentialFeed
import EssentialFeediOS
import Combine

final class FeedImagePresentationAdapter<Image, View: FeedImageView>: FeedImageCellControllerDelegate where Image == View.Image {
    private let model: FeedImage
    private let loader: (URL) -> FeedImageDataLoader.Publisher
    private var cancellable: Cancellable?
    
    var presenter: FeedImagePresenter<Image, View>?
    
    init(model: FeedImage, loader: @escaping (URL) -> FeedImageDataLoader.Publisher) {
        self.model = model
        self.loader = loader
    }
    
    func didRequestImage() {
        presenter?.startLoadingImageData(for: model)
        
        let model = self.model
        
        cancellable = loader(model.url).sink(
            receiveCompletion: { [weak presenter] completion in
                switch completion {
                case .finished: break
                case let .failure(error):
                    presenter?.endLoadingImageData(with: error, for: model)
                }
            },
            receiveValue: { [weak presenter] imageData in
                presenter?.endLoadingImageData(with: imageData, for: model)
            }
        )
    }
    
    func didCancelImageRequest() {
        cancellable?.cancel()
    }
}
