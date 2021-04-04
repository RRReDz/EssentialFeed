//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Riccardo Rossi - Home on 27/02/21.
//

import XCTest
import EssentialFeed

class CacheFeedUseCaseTests: XCTestCase {

    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_save_doesRequestCacheDeletion() {
        let (sut, store) = makeSUT()
        
        sut.save(uniqueImageFeed().model) { _ in }
        
        XCTAssertEqual(store.receivedMessages, [.deleteCacheFeed])
    }
    
    func test_save_doesNotRequestCacheInsertionOnDeletionError() {
        let (sut, store) = makeSUT()
        let delitionError = anyNSError()
        
        sut.save(uniqueImageFeed().model) { _ in }
        store.completeDeletion(with: delitionError)
        
        XCTAssertEqual(store.receivedMessages, [.deleteCacheFeed])
    }
    
    func test_save_doesRequestCacheInsertionWithTimestampOnDeletionSuccess() {
        let timestamp = Date()
        let (sut, store) = makeSUT(currentDate: { timestamp })
        let feed = uniqueImageFeed()
        
        sut.save(feed.model) { _ in }
        store.completeDeletionWithSuccess()
        
        XCTAssertEqual(store.receivedMessages, [.deleteCacheFeed, .insert(feed.local, timestamp)])
    }
    
    func test_save_failsOnDeletionError() {
        let (sut, store) = makeSUT()
        let delitionError = anyNSError()
        
        expect(sut, toCompleteWithError: delitionError, when: {
            store.completeDeletion(with: delitionError)
        })
    }
    
    func test_save_failsOnDeletionSuccessAndInsertionError() {
        let (sut, store) = makeSUT()
        let insertionError = anyNSError()
        
        expect(sut, toCompleteWithError: insertionError, when: {
            store.completeDeletionWithSuccess()
            store.completeInsertion(with: insertionError)
        })
    }
    
    func test_save_succeedOnDeletionSuccessAndInsertionSuccess() {
        let (sut, store) = makeSUT()
        
        expect(sut, toCompleteWithError: nil, when: {
            store.completeDeletionWithSuccess()
            store.completeInsertionWithSuccess()
        })
    }
    
    func test_save_doesNotDeliverErrorWhenCompletingDeletionWithErrorAndWhenSUTHasBeenDeallocated() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
        var capturedErrors: [LocalFeedLoader.SaveResult] = []
        
        sut?.save(uniqueImageFeed().model) { capturedErrors.append($0) }
        
        sut = nil
        store.completeDeletion(with: anyNSError())
        
        XCTAssert(capturedErrors.isEmpty)
    }
    
    func test_save_doesNotDeliverErrorWhenCompletingInsertionWithErrorAndWhenSUTHasBeenDeallocated() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
        var capturedErrors: [LocalFeedLoader.SaveResult] = []
        
        sut?.save(uniqueImageFeed().model) { capturedErrors.append($0) }
        
        store.completeDeletionWithSuccess()
        sut = nil
        store.completeInsertion(with: anyNSError())
        
        XCTAssert(capturedErrors.isEmpty)
    }
    
    // MARK: - Helpers
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut: sut, store: store)
    }
    
    private func expect(_ sut: LocalFeedLoader, toCompleteWithError error: Error?, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for save response")
        
        var capturedError: Error?
        sut.save(uniqueImageFeed().model) { result in
            if case let Result.failure(error) = result { capturedError = error }
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertEqual(capturedError as NSError?, error as NSError?, file: file, line: line)
    }
    
}
