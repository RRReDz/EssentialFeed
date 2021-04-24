//
//  FeedImageCellController.swift
//  EssentialFeediOS
//
//  Created by Riccardo Rossi - Home on 13/04/21.
//

import UIKit

protocol FeedImageCellControllerDelegate {
    func didRequestImage() -> Void
    func didCancelImageRequest() -> Void
}

final class FeedImageCellController {
    private var delegate: FeedImageCellControllerDelegate
    private weak var cell: FeedImageCell?
    
    init(delegate: FeedImageCellControllerDelegate) {
        self.delegate = delegate
    }
    
    func view() -> UITableViewCell {
        let cell = binded(FeedImageCell())
        delegate.didRequestImage()
        return cell
    }
    
    func preload() {
        delegate.didRequestImage()
    }
    
    func cancelLoad() {
        delegate.didCancelImageRequest()
    }
    
    private func binded(_ cell: FeedImageCell) -> FeedImageCell {
        cell.onRetry = delegate.didRequestImage
        
        self.cell = cell
        return cell
    }
}

extension FeedImageCellController: FeedImageView {
    func display(image: UIImage) {
        cell?.feedImageView.image = image
    }
}

extension FeedImageCellController: FeedImageLoadingView {
    func display(isLoading: Bool) {
        if isLoading {
            cell?.feedImageContainer.startShimmering()
        } else {
            cell?.feedImageContainer.stopShimmering()
        }
    }
}

extension FeedImageCellController: FeedImageRetryLoadingView {
    func display(retryImageLoading: Bool) {
        cell?.feedImageRetryButton.isHidden = !retryImageLoading
    }
}

extension FeedImageCellController: FeedImageStaticDataView {
    func display(_ viewModel: FeedImageStaticDataViewModel) {
        cell?.locationContainer.isHidden = viewModel.isLocationHidden
        cell?.locationLabel.text = viewModel.locationText
        cell?.descriptionLabel.text = viewModel.descriptionText
    }
}

