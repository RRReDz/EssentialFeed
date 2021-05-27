//
//  FeedPresenterTests.swift
//  EssentialFeedTests
//
//  Created by Riccardo Rossi - Home on 27/05/21.
//

import XCTest

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
    
    func didStartLoadingFeed() {
        loadingView.display(FeedLoadingViewModel(isLoading: true))
    }
}

class FeedPresenterTests: XCTestCase {

    func test_init_doesNotSendMessagesToView() {
        let view = ViewSpy()
        _ = FeedPresenter(loadingView: view)
        
        XCTAssertEqual(view.messages, [])
    }
    
    func test_didStartLoadingFeed_sendLoadingMessageToLoadingView() {
        let view = ViewSpy()
        let sut = FeedPresenter(loadingView: view)
        
        sut.didStartLoadingFeed()
        
        XCTAssertEqual(view.messages, [.isLoading(true)])
    }

    private class ViewSpy: FeedLoadingView {
        enum Message: Equatable {
            case isLoading(Bool)
        }
        
        var messages = [Message]()
        
        func display(_ viewModel: FeedLoadingViewModel) {
            messages.append(.isLoading(viewModel.isLoading))
        }
    }
}
