//
//  FeedViewController+TestHelpers.swift
//  EssentialFeediOSTests
//
//  Created by Riccardo Rossi - Home on 12/04/21.
//

import UIKit
import EssentialFeediOS

extension FeedViewController {
    func simulateUserInitiatedFeedReload() {
        refreshControl?.simulatePullToRefresh()
    }
    
    @discardableResult
    func simulateFeedImageViewVisible(at index: Int) -> FeedImageCell? {
        return feedImageView(at: index) as? FeedImageCell
    }
    
    func renderedFeedImageData(at index: Int) -> Data? {
        return simulateFeedImageViewVisible(at: index)?.renderedImageData
    }
    
    @discardableResult
    func simulateFeedImageViewNotVisible(at index: Int) -> FeedImageCell? {
        let cell = simulateFeedImageViewVisible(at: index)!
        
        let indexPath = IndexPath(row: index, section: feedImagesSection)
        let delegate = tableView.delegate
        delegate?.tableView?(tableView, didEndDisplaying: cell, forRowAt: indexPath)
        
        return cell
    }
    
    func simulateFeedImageViewNearVisible(at index: Int = 0) {
        let indexPath = IndexPath(row: index, section: feedImagesSection)
        let ds = tableView.prefetchDataSource
        ds?.tableView(tableView, prefetchRowsAt: [indexPath])
    }
    
    func simulateFeedImageViewNotNearVisible(at index: Int = 0) {
        simulateFeedImageViewNearVisible(at: index)
        
        let indexPath = IndexPath(row: index, section: feedImagesSection)
        let ds = tableView.prefetchDataSource
        ds?.tableView?(tableView, cancelPrefetchingForRowsAt: [indexPath])
    }
    
    func isShowingLoadingIndicator() -> Bool {
        return refreshControl!.isRefreshing
    }
    
    var errorMessage: String? {
        return errorView?.message
    }
    
    private var feedImagesSection: Int { return 0 }
    
    func numberOfRenderedFeedImageViews() -> Int {
        return tableView.numberOfRows(inSection: feedImagesSection)
    }
    
    func feedImageView(at row: Int) -> UITableViewCell? {
        guard numberOfRenderedFeedImageViews() > row else { return nil }
        let indexPath = IndexPath(row: row, section: feedImagesSection)
        let ds = tableView.dataSource
        return ds?.tableView(tableView, cellForRowAt: indexPath)
    }
}
