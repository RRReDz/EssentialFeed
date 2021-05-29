//
//  FeedPresenterTests.swift
//  EssentialFeedTests
//
//  Created by Riccardo Rossi - Home on 27/05/21.
//

import XCTest
import EssentialFeed

struct FeedViewModel {
    let feed: [FeedImage]
}

protocol FeedView {
    func display(_ viewModel: FeedViewModel)
}

protocol FeedLoadingView {
    func display(_ viewModel: FeedLoadingViewModel)
}

struct FeedLoadingViewModel {
    let isLoading: Bool
}

final class FeedPresenter {
    private let loadingView: FeedLoadingView
    private let feedView: FeedView
    
    init(feedView: FeedView, loadingView: FeedLoadingView) {
        self.feedView = feedView
        self.loadingView = loadingView
    }
    
    func didFinishLoadingFeed(with feed: [FeedImage]) {
        feedView.display(FeedViewModel(feed: feed))
        loadingView.display(FeedLoadingViewModel(isLoading: false))
    }
    
    func didStartLoadingFeed() {
        loadingView.display(FeedLoadingViewModel(isLoading: true))
    }
    
    func didFinishLoadingFeed(with error: Error) {
        loadingView.display(FeedLoadingViewModel(isLoading: false))
    }
}

class FeedPresenterTests: XCTestCase {

    func test_init_doesNotSendMessagesToView() {
        let (_, view) = makeSUT()
        
        XCTAssertEqual(view.messages, [])
    }
    
    func test_didStartLoadingFeed_startsLoadingView() {
        let (sut, view) = makeSUT()
        
        sut.didStartLoadingFeed()
        
        XCTAssertEqual(view.messages, [.display(loading: true)])
    }
    
    func test_didFinishLoadingFeed_stopsLoadingAndDisplaysFeed() {
        let (sut, view) = makeSUT()
        let feed = [uniqueImage()]
        
        sut.didFinishLoadingFeed(with: feed)
        
        XCTAssertEqual(view.messages, [.display(loading: false), .display(feed: feed)])
    }
    
    func test_didFinishLoadingFeed_stopsLoadingView() {
        let (sut, view) = makeSUT()
        let error = anyNSError()
        
        sut.didFinishLoadingFeed(with: error)
        
        XCTAssertEqual(view.messages, [.display(loading: false)])
    }
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedPresenter, view: ViewSpy) {
        let view = ViewSpy()
        let sut = FeedPresenter(feedView: view, loadingView: view)
        trackForMemoryLeaks(view, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, view)
    }

    private class ViewSpy: FeedLoadingView, FeedView {
        enum Message: Hashable {
            case display(loading: Bool)
            case display(feed: [FeedImage])
        }
        
        var messages = Set<Message>()
        
        func display(_ viewModel: FeedLoadingViewModel) {
            messages.insert(.display(loading: viewModel.isLoading))
        }
        
        func display(_ viewModel: FeedViewModel) {
            messages.insert(.display(feed: viewModel.feed))
        }
    }
}
