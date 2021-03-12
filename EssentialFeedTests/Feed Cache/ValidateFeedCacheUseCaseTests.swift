//
//  ValidateFeedCacheUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Riccardo Rossi - Home on 12/03/21.
//

import XCTest
import EssentialFeed

class ValidateFeedCacheUseCaseTests: XCTestCase {

    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_validateCache_deletesCacheOnRetrievalError() {
        let (sut, store) = makeSUT()
        
        sut.validateCache()
        store.completeRetrieval(with: anyNSError())
        
        XCTAssertEqual(store.receivedMessages, [.retrieve, .deleteCacheFeed])
    }
    
    func test_validateCache_doesNotDeleteCacheOnEmptyCache() {
        let (sut, store) = makeSUT()

        sut.validateCache()
        store.completeRetrievalSuccessfullyWithEmptyCache()

        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_validateCache_doesNotDeleteCacheOnNonExpiredCache() {
        let fixedCurrentDate = Date()
        let nonExpiredTimestamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: 1)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        
        sut.validateCache()
        store.completeRetrieval(with: uniqueImageFeed().local, timestamp: nonExpiredTimestamp)
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_validateCache_deletesCacheOnCacheExpiration() {
        let fixedCurrentDate = Date()
        let expirationTimestamp = fixedCurrentDate.minusFeedCacheMaxAge()
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })

        sut.validateCache()
        store.completeRetrieval(with: uniqueImageFeed().local, timestamp: expirationTimestamp)

        XCTAssertEqual(store.receivedMessages, [.retrieve, .deleteCacheFeed])
    }
    
    func test_validateCache_deletesCacheOnExpiredCache() {
        let fixedCurrentDate = Date()
        let expiredTimestamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(days: -1)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })

        sut.validateCache()
        store.completeRetrieval(with: uniqueImageFeed().local, timestamp: expiredTimestamp)

        XCTAssertEqual(store.receivedMessages, [.retrieve, .deleteCacheFeed])
    }
    
    func test_validateCache_doesDeleteCacheWhenSUTInstanceHasBeenDeallocated() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
        
        sut?.validateCache()
        sut = nil
        store.completeRetrieval(with: anyNSError())
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    // MARK: - Helpers
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut: sut, store: store)
    }

}
