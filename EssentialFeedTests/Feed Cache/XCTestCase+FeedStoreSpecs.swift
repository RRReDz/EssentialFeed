//
//  XCTestCase+FeedStoreSpecs.swift
//  EssentialFeedTests
//
//  Created by Riccardo Rossi - Home on 20/03/21.
//

import XCTest
import EssentialFeed

extension FeedStoreSpecs where Self: XCTestCase {
    func assertThatRetrieveDeliversEmptyOnEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        expect(sut, toRetrieve: .empty, file: file, line: line)
    }
    
    func assertThatRetrieveHasNoSideEffectsOnEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        expect(sut, toRetrieveTwice: .empty, file: file, line: line)
    }
    
    func assertThatRetrieveDeliversFoundValuesOnNonEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        let feed = uniqueImageFeed().local
        let timestamp = Date()
        insert(cache: (feed, timestamp), to: sut, file: file, line: line)
        
        expect(sut, toRetrieve: .found(feed: feed, timestamp: timestamp), file: file, line: line)
    }
    
    func assertThatRetrieveHasNoSideEffectsOnNonEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        let feed = uniqueImageFeed().local
        let timestamp = Date()
        insert(cache: (feed, timestamp), to: sut, file: file, line: line)
        
        expect(sut, toRetrieveTwice: .found(feed: feed, timestamp: timestamp), file: file, line: line)
    }
    
    func assertThatInsertDeliversNoErrorOnEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        let insertionError = insert(cache: (uniqueImageFeed().local, Date()), to: sut, file: file, line: line)
        
        XCTAssertNil(insertionError, "Expected the insertion to complete without error", file: file, line: line)
    }
    
    func assertThatInsertDeliversNoErrorOnNonEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        insert(cache: (uniqueImageFeed().local, Date()), to: sut, file: file, line: line)
        
        let latestFeed = uniqueImageFeed().local
        let latestTimestamp = Date()
        let secondInsertionError = insert(cache: (feed: latestFeed, timestamp: latestTimestamp), to: sut, file: file, line: line)
        
        XCTAssertNil(secondInsertionError, "Expected to override cache successfully", file: file, line: line)
    }
    
    func assertThatInsertOverridesPreviouslyInsertedCacheValues(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        insert(cache: (uniqueImageFeed().local, Date()), to: sut, file: file, line: line)
        
        let latestFeed = uniqueImageFeed().local
        let latestTimestamp = Date()
        insert(cache: (feed: latestFeed, timestamp: latestTimestamp), to: sut, file: file, line: line)
        
        expect(sut, toRetrieve: .found(feed: latestFeed, timestamp: latestTimestamp), file: file, line: line)
    }
    
    func assertThatDeleteHasNoSideEffectsOnEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        deleteCache(from: sut, file: file, line: line)
        
        expect(sut, toRetrieve: .empty, file: file, line: line)
    }
    
    func assertThatDeleteDoesNotDeliverErrorOnEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        let deletionError = deleteCache(from: sut, file: file, line: line)
        
        XCTAssertNil(deletionError, "Expected the deletion to complete without errors", file: file, line: line)
    }
    
    func assertThatDeleteDoesNotDelivererrorOnNonEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        insert(cache: (uniqueImageFeed().local, Date()), to: sut, file: file, line: line)
        
        let deletionError = deleteCache(from: sut, file: file, line: line)
        
        XCTAssertNil(deletionError, "Expected the deletion to complete without errors", file: file, line: line)
    }
    
    func assertThatDeleteLeavesCacheEmptyOnNonEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        insert(cache: (uniqueImageFeed().local, Date()), to: sut, file: file, line: line)
        
        deleteCache(from: sut, file: file, line: line)
        
        expect(sut, toRetrieve: .empty, file: file, line: line)
    }
    
    func assertThatStoreSideEffectsRunSerially(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        var completedOperations: [XCTestExpectation] = []
        
        let exp1 = expectation(description: "Operation 1")
        sut.insert(uniqueImageFeed().local, timestamp: Date()) { _ in
            completedOperations.append(exp1)
            exp1.fulfill()
        }
        
        let exp2 = expectation(description: "Operation 2")
        sut.deleteCachedFeed { _ in
            completedOperations.append(exp2)
            exp2.fulfill()
        }
        
        let exp3 = expectation(description: "Operation 3")
        sut.insert(uniqueImageFeed().local, timestamp: Date()) { _ in
            completedOperations.append(exp3)
            exp3.fulfill()
        }
        
        waitForExpectations(timeout: 5.0)
        
        XCTAssertEqual(completedOperations, [exp1, exp2, exp3], "Expected side-effects to run serially but operations finished in the wrong order", file: file, line: line)
    }
    
    func expect(_ sut: FeedStore, toRetrieve expectedResult: RetrieveCachedFeedResult, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for cache retrieval")
        
        sut.retrieve { retrievedResult in
            switch (retrievedResult, expectedResult) {
            case (.empty, .empty), (.failure, .failure):
                break
                
            case let (.found(feed: retrievedFeed, timestamp: retrievedTimestamp), .found(feed: expectedFeed, timestamp: expectedTimestamp)):
                XCTAssertEqual(retrievedFeed, expectedFeed, file: file, line: line)
                XCTAssertEqual(retrievedTimestamp, expectedTimestamp, file: file, line: line)
                
            default:
                XCTFail("Expected to retrieve \(expectedResult), got \(retrievedResult) instead", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func expect(_ sut: FeedStore, toRetrieveTwice expectedResult: RetrieveCachedFeedResult, file: StaticString = #file, line: UInt = #line) {
        expect(sut, toRetrieve: expectedResult)
        expect(sut, toRetrieve: expectedResult)
    }
    
    @discardableResult
    func insert(cache: (feed: [LocalFeedImage], timestamp: Date), to sut: FeedStore, file: StaticString = #file, line: UInt = #line) -> Error? {
        let exp = expectation(description: "Wait for retrieve result")
        var capturedError: Error?
        sut.insert(cache.feed, timestamp: cache.timestamp) { insertionError in
            capturedError = insertionError
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        return capturedError
    }
    
    @discardableResult
    func deleteCache(from sut: FeedStore, file: StaticString = #file, line: UInt = #line) -> Error? {
        let exp = expectation(description: "Wait for delete completion")
        var capturedError: Error?
        sut.deleteCachedFeed { error in
            capturedError = error
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        return capturedError
    }
}
