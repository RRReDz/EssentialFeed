//
//  FeedRefreshViewController.swift
//  EssentialFeediOS
//
//  Created by Riccardo Rossi - Home on 12/04/21.
//

import UIKit
import EssentialFeed

protocol FeedRefreshControllerDelegate {
    func didRequestFeedRefresh()
}

final class FeedRefreshController: NSObject {
    private(set) lazy var view: UIRefreshControl = loadView()
    
    private let delegate: FeedRefreshControllerDelegate
    
    init(delegate: FeedRefreshControllerDelegate) {
        self.delegate = delegate
    }
    
    @objc func refresh() {
        delegate.didRequestFeedRefresh()
    }
    
    private func loadView() -> UIRefreshControl {
        let view = UIRefreshControl()
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return view
    }

}

extension FeedRefreshController: FeedLoadingView {
    func display(_ viewModel: FeedLoadingViewModel) {
        if viewModel.isLoading {
            view.beginRefreshing()
        } else {
            view.endRefreshing()
        }
    }
}
