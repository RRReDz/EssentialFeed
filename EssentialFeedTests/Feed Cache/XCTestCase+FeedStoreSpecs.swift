//
//  XCTestCase+FeedStoreSpecs.swift
//  EssentialFeedTests
//
//  Created by Riccardo Rossi - Home on 20/03/21.
//

import XCTest
import EssentialFeed

extension FeedStoreSpecs where Self: XCTestCase {
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
