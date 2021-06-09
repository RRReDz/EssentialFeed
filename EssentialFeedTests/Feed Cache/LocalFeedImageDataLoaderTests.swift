//
//  LocalFeedImageDataLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Riccardo Rossi - Home on 09/06/21.
//

import XCTest

final class LocalFeedImageDataLoader {
    init(store: Any) {}
}

class LocalFeedImageDataLoaderTests: XCTestCase {

    func test_init_doesNotMessageStoreUponCreation() {
        let store = StoreSpy()
        _ = LocalFeedImageDataLoader(store: store)
        
        XCTAssert(store.messages.isEmpty)
    }
    
    private final class StoreSpy {
        var messages = [Any]()
    }
}
