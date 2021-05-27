//
//  FeedPresenterTests.swift
//  EssentialFeedTests
//
//  Created by Riccardo Rossi - Home on 27/05/21.
//

import XCTest

final class FeedPresenter {
    init(view: Any) {}
}

class FeedPresenterTests: XCTestCase {

    func test_init_doesNotSendMessagesToView() {
        let view = ViewSpy()
        _ = FeedPresenter(view: view)
        
        XCTAssertTrue(view.messages.isEmpty)
    }

    private class ViewSpy {
        var messages = [Any]()
    }
}
