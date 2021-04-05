//
//  FeedViewControllerTests.swift
//  EssentialFeediOSTests
//
//  Created by Riccardo Rossi - Home on 05/04/21.
//

import XCTest

final class FeedViewController {
    init(loader: FeedViewControllerTests.LoaderSpy) {}
}

class FeedViewControllerTests: XCTestCase {

    func test_init_doesNotLoadFeed() {
        let loader = LoaderSpy()
        _ = FeedViewController(loader: loader)
        
        XCTAssertEqual(loader.loadCallCount, 0)
    }
    
    final class LoaderSpy {
        private(set) var loadCallCount: Int = 0
    }
}
