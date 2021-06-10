//
//  CacheFeedImageDataUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Riccardo Rossi - Home on 10/06/21.
//

import XCTest
import EssentialFeed

class CacheFeedImageDataUseCaseTests: XCTestCase {

    func test_saveImageData_requestsImageDataInsertion() {
        let (sut, store) = makeSUT()
        let url = anyURL()
        let data = anyData()
        
        sut.save(data: data, for: url)
        
        XCTAssertEqual(store.messages, [.insert(data, for: url)])
    }
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedImageDataLoader, store: FeedImageDataStoreSpy) {
        let store = FeedImageDataStoreSpy()
        let sut = LocalFeedImageDataLoader(store: store)
        trackForMemoryLeaks(store)
        trackForMemoryLeaks(sut)
        return (sut, store)
    }

}
