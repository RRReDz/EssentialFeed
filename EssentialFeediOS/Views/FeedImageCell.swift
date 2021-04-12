//
//  FeedImageCell.swift
//  EssentialFeediOS
//
//  Created by Riccardo Rossi - Home on 06/04/21.
//

import UIKit

public final class FeedImageCell: UITableViewCell {
    public var locationContainer = UIView()
    public var descriptionLabel = UILabel()
    public var locationLabel = UILabel()
    public var feedImageContainer = UIView()
    public var feedImageView = UIImageView()
    private(set) public lazy var feedImageRetryButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(feedImageRetryButtonTapped), for: .touchUpInside)
        return button
    }()
    var onRetry: (() -> Void)?
    
    @objc private func feedImageRetryButtonTapped() {
        onRetry?()
    }
}
