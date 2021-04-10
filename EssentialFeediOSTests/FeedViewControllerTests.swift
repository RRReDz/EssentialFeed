//
//  FeedViewControllerTests.swift
//  EssentialFeediOSTests
//
//  Created by Riccardo Rossi - Home on 05/04/21.
//

import XCTest
import UIKit
import EssentialFeed
import EssentialFeediOS

class FeedViewControllerTests: XCTestCase {

    func test_loadFeedActions_requestFeedFromLoader() {
        let (sut, loader) = makeSUT()
        XCTAssertEqual(loader.loadFeedCallCount, 0, "Expected no loading requests before view is loaded")
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.loadFeedCallCount, 1, "Expected a loading request once view is loaded")
        
        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(loader.loadFeedCallCount, 2, "Expected another loading request once user initiated a load")
        
        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(loader.loadFeedCallCount, 3, "Expected a third loading request once user initiated another load")
    }
    
    func test_loadingFeedIndicator_isVisibleWhileLoadingFeed() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        XCTAssertTrue(sut.isShowingLoadingIndicator(), "Expected loading indicator once view is loaded")
        
        loader.completeLoad(at: 0)
        XCTAssertFalse(sut.isShowingLoadingIndicator(), "Expected no loading indicator once loading completes successfully")
    
        sut.simulateUserInitiatedFeedReload()
        XCTAssertTrue(sut.isShowingLoadingIndicator(), "Expected loading indicator once user initiates a reload")
        
        loader.completeLoadWithError(at: 1)
        XCTAssertFalse(sut.isShowingLoadingIndicator(), "Expected no loading indicator once user initiated loading completes with error")
    }
    
    func test_loadFeedCompletion_rendersSuccessfullyLoadedFeed() {
        let image0 = makeImage(description: "a description", location: "a location")
        let image1 = makeImage(description: nil, location: "another location")
        let image2 = makeImage(description: "another description", location: nil)
        let image3 = makeImage(description: nil, location: nil)
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(sut.numberOfRenderedFeedImageViews(), 0)
        assertThat(sut, isRendering: [])
        
        loader.completeLoad(with: [image0], at: 0)
        assertThat(sut, isRendering: [image0])
        
        sut.simulateUserInitiatedFeedReload()
        loader.completeLoad(with: [image0, image1, image2, image3], at: 1)
        assertThat(sut, isRendering: [image0, image1, image2, image3])
    }
    
    func test_loadFeedCompletion_doesNotAlterCurrentRenderingStateOnError() {
        let image0 = makeImage(description: "a description", location: "a location")
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        loader.completeLoad(with: [image0], at: 0)
        assertThat(sut, isRendering: [image0])
        
        sut.simulateUserInitiatedFeedReload()
        loader.completeLoadWithError(at: 1)
        assertThat(sut, isRendering: [image0])
    }
    
    func test_feedImageView_loadsImageURLWhenVisible() {
        let image0 = makeImage(url: URL(string: "http://url-0.com")!)
        let image1 = makeImage(url: URL(string: "http://url-1.com")!)
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeLoad(with: [image0, image1], at: 0)
        
        XCTAssertEqual(loader.loadedImageURLs, [], "Expected no image URL requests until views become visible")
        
        sut.simulateFeedImageViewVisible(at: 0)
        XCTAssertEqual(loader.loadedImageURLs, [image0.url], "Expected image0 URL has been requested")
        
        sut.simulateFeedImageViewVisible(at: 1)
        XCTAssertEqual(loader.loadedImageURLs, [image0.url, image1.url], "Expected image0 and image1 URLs has been requested")
    }
    
    func test_feedImageView_cancelImageURLRequestWhenInvisible() {
        let image0 = makeImage(url: URL(string: "http://url-0.com")!)
        let image1 = makeImage(url: URL(string: "http://url-1.com")!)
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeLoad(with: [image0, image1], at: 0)
        
        XCTAssertEqual(loader.canceledImageURLs, [], "Expected no image URL requests until views become visible")
        
        sut.simulateFeedImageViewNotVisible(at: 0)
        XCTAssertEqual(loader.canceledImageURLs, [image0.url], "Expected image0 URL has been requested")
        
        sut.simulateFeedImageViewNotVisible(at: 1)
        XCTAssertEqual(loader.canceledImageURLs, [image0.url, image1.url], "Expected image0 and image1 requests has been canceled")
    }
    
    final class LoaderSpy: FeedLoader, FeedImageDataLoader {
        
        // MARK: - FeedLoader
        
        private var feedRequests: [(Result<[FeedImage], Error>) -> Void] = []
        
        var loadFeedCallCount: Int {
            return feedRequests.count
        }
        
        func load(completion: @escaping (Result<[FeedImage], Error>) -> Void) {
            feedRequests.append(completion)
        }
        
        func completeLoad(with feed: [FeedImage] = [], at index: Int) {
            feedRequests[index](.success(feed))
        }
        
        func completeLoadWithError(at index: Int) {
            let error = NSError(domain: "Foo Error", code: 1)
            feedRequests[index](.failure(error))
        }
        
        // MARK: - FeedImageDataLoader
        
        private(set) var loadedImageURLs: [URL] = []
        private(set) var canceledImageURLs: [URL] = []
        
        private struct TaskSpy: FeedImageDataLoaderTask {
            let onCancel: () -> Void
            
            func cancel() {
                onCancel()
            }
        }
        
        func loadImageData(from url: URL) -> FeedImageDataLoaderTask {
            loadedImageURLs.append(url)
            return TaskSpy { [weak self] in
                self?.canceledImageURLs.append(url)
            }
        }
        
    }
    
    // MARK: - Private
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = FeedViewController(feedLoader: loader, imageLoader: loader)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(loader, file: file, line: line)
        return (sut, loader)
    }
    
    private func makeImage(description: String? = nil, location: String? = nil, url: URL = URL(string: "http://any-url.com")!) -> FeedImage {
        return FeedImage(id: UUID(), description: description, location: location, url: url)
    }
    
    private func assertThat(_ sut: FeedViewController, hasViewConfiguredFor feedImage: FeedImage, at index: Int, file: StaticString = #file, line: UInt = #line) {
        let view = sut.feedImageView(at: index) as? FeedImageCell
        XCTAssertNotNil(view, file: file, line: line)
        XCTAssertEqual(view?.isShowingLocation, feedImage.location != nil, file: file, line: line)
        XCTAssertEqual(view?.descriptionText, feedImage.description, file: file, line: line)
        XCTAssertEqual(view?.locationText, feedImage.location, file: file, line: line)
    }
    
    private func assertThat(_ sut: FeedViewController, isRendering images: [FeedImage], file: StaticString = #file, line: UInt = #line) {
        XCTAssertEqual(sut.numberOfRenderedFeedImageViews(), images.count, file: file, line: line)
        images.enumerated().forEach { index, image in
            assertThat(sut, hasViewConfiguredFor: image, at: index, file: file, line: line)
        }
    }
}

private extension FeedViewController {
    func simulateUserInitiatedFeedReload() {
        refreshControl?.simulatePullToRefresh()
    }
    
    @discardableResult
    func simulateFeedImageViewVisible(at index: Int) -> FeedImageCell? {
        return feedImageView(at: index) as? FeedImageCell
    }
    
    func simulateFeedImageViewNotVisible(at index: Int) {
        let cell = simulateFeedImageViewVisible(at: index)!
        
        let indexPath = IndexPath(row: index, section: feedImagesSection)
        let delegate = tableView.delegate
        delegate?.tableView?(tableView, didEndDisplaying: cell, forRowAt: indexPath)
    }
    
    func isShowingLoadingIndicator() -> Bool {
        return refreshControl!.isRefreshing
    }
    
    private var feedImagesSection: Int { return 0 }
    
    func numberOfRenderedFeedImageViews() -> Int {
        return tableView.numberOfRows(inSection: feedImagesSection)
    }
    
    func feedImageView(at row: Int) -> UITableViewCell? {
        let indexPath = IndexPath(row: row, section: feedImagesSection)
        let ds = tableView.dataSource
        return ds?.tableView(tableView, cellForRowAt: indexPath)
    }
}

private extension FeedImageCell {
    var isShowingLocation: Bool {
        return !locationContainer.isHidden
    }
    
    var descriptionText: String? {
        return descriptionLabel.text
    }
    
    var locationText: String? {
        return locationLabel.text
    }
}

private extension UIRefreshControl {
    func simulatePullToRefresh() {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: .valueChanged)?.forEach {
                (target as NSObject).perform(Selector($0))
            }
        }
    }
}
