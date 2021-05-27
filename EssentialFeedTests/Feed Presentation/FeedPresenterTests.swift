//
//  FeedPresenterTests.swift
//  EssentialFeedTests
//
//  Created by Riccardo Rossi - Home on 27/05/21.
//

import XCTest
import EssentialFeed

protocol FeedLoadingView {
    func display(_ viewModel: FeedLoadingViewModel)
}

struct FeedLoadingViewModel {
    let isLoading: Bool
}

final class FeedPresenter {
    private let loadingView: FeedLoadingView
    
    init(loadingView: FeedLoadingView) {
        self.loadingView = loadingView
    }
    
    func didFinishLoadingFeed(with feed: [FeedImage]) {
        loadingView.display(FeedLoadingViewModel(isLoading: false))
    }
    
    func didStartLoadingFeed() {
        loadingView.display(FeedLoadingViewModel(isLoading: true))
    }
}

class FeedPresenterTests: XCTestCase {

    func test_init_doesNotSendMessagesToView() {
        let (_, view) = makeSUT()
        
        XCTAssertEqual(view.messages, [])
    }
    
    func test_didStartLoadingFeed_sendLoadingMessageToLoadingView() {
        let (sut, view) = makeSUT()
        
        sut.didStartLoadingFeed()
        
        XCTAssertEqual(view.messages, [.display(loading: true)])
    }
    
    func test_didFinishLoadingFeed_sendNotLoadingMessageToLoadingView() {
        let (sut, view) = makeSUT()
        
        sut.didFinishLoadingFeed(with: [uniqueImage()])
        
        XCTAssertEqual(view.messages, [.display(loading: false)])
    }
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedPresenter, view: ViewSpy) {
        let view = ViewSpy()
        let sut = FeedPresenter(loadingView: view)
        trackForMemoryLeaks(view, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, view)
    }

    private class ViewSpy: FeedLoadingView {
        enum Message: Equatable {
            case display(loading: Bool)
        }
        
        var messages = [Message]()
        
        func display(_ viewModel: FeedLoadingViewModel) {
            messages.append(.display(loading: viewModel.isLoading))
        }
    }
}
