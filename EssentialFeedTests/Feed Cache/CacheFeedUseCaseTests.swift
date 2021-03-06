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
        
        sut.save(uniqueItems().model) { _ in }
        
        XCTAssertEqual(store.receivedMessages, [.deleteCacheFeed])
    }
    
    func test_save_doesNotRequestCacheInsertionOnDeletionError() {
        let (sut, store) = makeSUT()
        let delitionError = anyNSError()
        
        sut.save(uniqueItems().model) { _ in }
        store.completeDeletion(with: delitionError)
        
        XCTAssertEqual(store.receivedMessages, [.deleteCacheFeed])
    }
    
    func test_save_doesRequestCacheInsertionWithTimestampOnDeletionSuccess() {
        let timestamp = Date()
        let (sut, store) = makeSUT(currentDate: { timestamp })
        let items = uniqueItems()
        
        sut.save(items.model) { _ in }
        store.completeDeletionWithSuccess()
        
        XCTAssertEqual(store.receivedMessages, [.deleteCacheFeed, .insert(items.local, timestamp)])
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
        
        sut?.save(uniqueItems().model) { capturedErrors.append($0) }
        
        sut = nil
        store.completeDeletion(with: anyNSError())
        
        XCTAssert(capturedErrors.isEmpty)
    }
    
    func test_save_doesNotDeliverErrorWhenCompletingInsertionWithErrorAndWhenSUTHasBeenDeallocated() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
        var capturedErrors: [LocalFeedLoader.SaveResult] = []
        
        sut?.save(uniqueItems().model) { capturedErrors.append($0) }
        
        store.completeDeletionWithSuccess()
        sut = nil
        store.completeInsertion(with: anyNSError())
        
        XCTAssert(capturedErrors.isEmpty)
    }
    
    // MARK: - Helpers
    class FeedStoreSpy: FeedStore {
        enum ReceivedMessage: Equatable {
            case insert([LocalFeedItem], Date)
            case deleteCacheFeed
        }
        
        private(set) var receivedMessages: [ReceivedMessage] = []
        
        var deletionCompletions: [DeletionCompletion] = []
        var insertionCompletions: [InsertionCompletion] = []
        
        // Called by LocalFeedLoader
        
        func deleteCachedFeed(completion: @escaping DeletionCompletion) {
            deletionCompletions.append(completion)
            receivedMessages.append(.deleteCacheFeed)
        }
        
        func insert(_ items: [LocalFeedItem], timestamp: Date, completion: @escaping InsertionCompletion) {
            insertionCompletions.append(completion)
            receivedMessages.append(.insert(items, timestamp))
        }
        
        // Called by Tests
        
        func completeDeletion(with error: Error, at index: Int = 0) {
            deletionCompletions[index](error)
        }
        
        func completeInsertion(with error: Error, at index: Int = 0) {
            insertionCompletions[index](error)
        }
        
        func completeDeletionWithSuccess(at index: Int = 0) {
            deletionCompletions[index](nil)
        }
        
        func completeInsertionWithSuccess(at index: Int = 0) {
            insertionCompletions[index](nil)
        }
    }
    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut: sut, store: store)
    }
    
    private func expect(_ sut: LocalFeedLoader, toCompleteWithError error: Error?, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for save response")
        
        var capturedResult: LocalFeedLoader.SaveResult = nil
        sut.save(uniqueItems().model) { result in
            capturedResult = result
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertEqual(capturedResult as NSError?, error as NSError?, file: file, line: line)
    }
    
    private func uniqueItem() -> FeedItem {
        return FeedItem(
            id: UUID(),
            description: "Any description",
            location: "Any location",
            imageURL: anyURL()
        )
    }
    
    private func uniqueItems() -> (model: [FeedItem], local: [LocalFeedItem]) {
        let items = [uniqueItem(), uniqueItem()]
        let localItems = items.map {
            LocalFeedItem(
                id: $0.id,
                description: $0.description,
                location: $0.location,
                imageURL: $0.imageURL
            )
        }
        return (items, localItems)
    }
    
    private func anyURL() -> URL {
        return URL(string: "http://any-url.com")!
    }
    
    private func anyNSError() -> NSError {
        return NSError(domain: "Foo Error", code: 1)
    }
}
