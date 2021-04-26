//
//  FeedRefreshViewController.swift
//  EssentialFeediOS
//
//  Created by Riccardo Rossi - Home on 12/04/21.
//

import Foundation
import UIKit

protocol FeedRefreshControllerDelegate {
    func didRequestFeedRefresh()
}

final class FeedRefreshController: NSObject {
    @IBOutlet private var view: UIRefreshControl!
    
    var delegate: FeedRefreshControllerDelegate?
    
    @IBAction func refresh() {
        delegate?.didRequestFeedRefresh()
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
