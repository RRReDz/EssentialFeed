//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Riccardo Rossi - Home on 27/02/21.
//

import XCTest
import EssentialFeed

class LocalFeedLoader {
    let store: FeedStore
    let currentDate: () -> Date
    
    init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
    func save(_ items: [FeedItem], completion: @escaping (Error?) -> Void) {
        store.deleteCachedFeed { [unowned self] error in
            if error == nil {
                self.store.insert(items, timestamp: self.currentDate(), completion: completion)
            } else {
                completion(error)
            }
        }
    }
}

class FeedStore {
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void
    
    enum ReceivedMessage: Equatable {
        case insert([FeedItem], Date)
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
    
    func insert(_ items: [FeedItem], timestamp: Date, completion: @escaping InsertionCompletion) {
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

class CacheFeedUseCaseTests: XCTestCase {

    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_save_doesRequestCacheDeletion() {
        let (sut, store) = makeSUT()
        let items = [uniqueItem(), uniqueItem()]
        
        sut.save(items) { _ in }
        
        XCTAssertEqual(store.receivedMessages, [.deleteCacheFeed])
    }
    
    func test_save_doesNotRequestCacheInsertionOnDeletionError() {
        let (sut, store) = makeSUT()
        let items = [uniqueItem(), uniqueItem()]
        let delitionError = anyNSError()
        
        sut.save(items) { _ in }
        store.completeDeletion(with: delitionError)
        
        XCTAssertEqual(store.receivedMessages, [.deleteCacheFeed])
    }
    
    func test_save_doesRequestCacheInsertionWithTimestampOnDeletionSuccess() {
        let timestamp = Date()
        let (sut, store) = makeSUT(currentDate: { timestamp })
        let items = [uniqueItem(), uniqueItem()]
        
        sut.save(items) { _ in }
        store.completeDeletionWithSuccess()
        
        XCTAssertEqual(store.receivedMessages, [.deleteCacheFeed, .insert(items, timestamp)])
    }
    
    func test_save_failsOnDeletionError() {
        let (sut, store) = makeSUT()
        let items = [uniqueItem(), uniqueItem()]
        let delitionError = anyNSError()
        let exp = expectation(description: "Wait for save response")
        
        var capturedError: Error?
        sut.save(items) { error in
            capturedError = error
            exp.fulfill()
        }
        store.completeDeletion(with: delitionError)
        
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertEqual(capturedError as NSError?, delitionError)
    }
    
    func test_save_failsOnDeletionSuccessAndInsertionError() {
        let (sut, store) = makeSUT()
        let items = [uniqueItem(), uniqueItem()]
        let insertionError = anyNSError()
        let exp = expectation(description: "Wait for save response")
        
        var capturedError: Error?
        sut.save(items) { error in
            capturedError = error
            exp.fulfill()
        }
        store.completeDeletionWithSuccess()
        store.completeInsertion(with: insertionError)
        
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertEqual(capturedError as NSError?, insertionError)
    }
    
    func test_save_succeedOnDeletionSuccessAndInsertionSuccess() {
        let (sut, store) = makeSUT()
        let items = [uniqueItem(), uniqueItem()]
        let exp = expectation(description: "Wait for save response")
        
        var capturedError: Error?
        sut.save(items) { error in
            capturedError = error
            exp.fulfill()
        }
        store.completeDeletionWithSuccess()
        store.completeInsertionWithSuccess()
        
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertNil(capturedError)
    }
    
    // MARK: - Helpers
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStore) {
        let store = FeedStore()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut: sut, store: store)
    }
    
    private func uniqueItem() -> FeedItem {
        return FeedItem(
            id: UUID(),
            description: "Any description",
            location: "Any location",
            imageURL: anyURL()
        )
    }
    
    private func anyURL() -> URL {
        return URL(string: "http://any-url.com")!
    }
    
    private func anyNSError() -> NSError {
        return NSError(domain: "Foo Error", code: 1)
    }
}
