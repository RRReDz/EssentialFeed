//
//  FeedImagePresenterTests.swift
//  EssentialFeedTests
//
//  Created by Riccardo Rossi - Home on 30/05/21.
//

import XCTest

final class FeedImagePresenter {
    init(view: Any) {}
}

class FeedImagePresenterTests: XCTestCase {
    func test_init_doesNotSendMessageToView() {
        let view = ViewSpy()
        
        _ = FeedImagePresenter(view: view)
        
        XCTAssert(view.messages.isEmpty)
    }
    
    private final class ViewSpy {
        var messages = [Any]()
    }
}
