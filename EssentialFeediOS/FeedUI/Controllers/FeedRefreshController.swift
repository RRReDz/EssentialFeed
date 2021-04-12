//
//  FeedRefreshViewController.swift
//  EssentialFeediOS
//
//  Created by Riccardo Rossi - Home on 12/04/21.
//

import Foundation
import UIKit
import EssentialFeed

final class FeedRefreshController: NSObject {
    private(set) lazy var view: UIRefreshControl = {
        let view = UIRefreshControl()
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return view
    }()
    
    private let feedLoader: FeedLoader
    
    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
    
    var onRefresh: (([FeedImage]) -> Void)?
    
    @objc func refresh() {
        view.beginRefreshing()
        feedLoader.load { [weak self] result in
            if let tableModel = try? result.get() {
                self?.onRefresh?(tableModel)
            }
            self?.view.endRefreshing()
        }
    }
}
