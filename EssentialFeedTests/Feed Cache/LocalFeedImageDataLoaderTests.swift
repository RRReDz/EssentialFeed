//
//  LocalFeedImageDataLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Riccardo Rossi - Home on 09/06/21.
//

import XCTest

protocol FeedImageDataStore {
    func retrieve(dataFrom url: URL)
}

final class LocalFeedImageDataLoader {
    private let store: FeedImageDataStore
    
    init(store: FeedImageDataStore) {
        self.store = store
    }
    
    func loadImageData(from url: URL) {
        store.retrieve(dataFrom: url)
    }
}

class LocalFeedImageDataLoaderTests: XCTestCase {

    func test_init_doesNotMessageStoreUponCreation() {
        let store = StoreSpy()
        _ = LocalFeedImageDataLoader(store: store)
        
        XCTAssert(store.messages.isEmpty)
    }
    
    func test_loadImageData_requestsStoreDataRetrieval() {
        let store = StoreSpy()
        let sut = LocalFeedImageDataLoader(store: store)
        let url = anyURL()
        
        sut.loadImageData(from: url)
        
        XCTAssertEqual(store.messages, [.retrieve(dataFor: url)])
    }
    
    private final class StoreSpy: FeedImageDataStore {
        enum Message: Equatable {
            case retrieve(dataFor: URL)
        }
        
        var messages = [Message]()

        func retrieve(dataFrom url: URL) {
            messages.append(.retrieve(dataFor: url))
        }
    }
}
