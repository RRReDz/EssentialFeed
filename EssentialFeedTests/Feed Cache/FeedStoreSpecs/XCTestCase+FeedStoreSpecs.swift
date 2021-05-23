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
        expect(sut, toRetrieve: .success(.none), file: file, line: line)
    }
    
    func assertThatRetrieveHasNoSideEffectsOnEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        expect(sut, toRetrieveTwice: .success(.none), file: file, line: line)
    }
    
    func assertThatRetrieveDeliversFoundValuesOnNonEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        let feed = uniqueImageFeed().local
        let timestamp = Date()
        insert(cache: (feed, timestamp), to: sut, file: file, line: line)
        
        expect(sut, toRetrieve: .success(.some((feed, timestamp))), file: file, line: line)
    }
    
    func assertThatRetrieveHasNoSideEffectsOnNonEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        let feed = uniqueImageFeed().local
        let timestamp = Date()
        insert(cache: (feed, timestamp), to: sut, file: file, line: line)
        
        expect(sut, toRetrieveTwice: .success(.some((feed, timestamp))), file: file, line: line)
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
        
        expect(sut, toRetrieve: .success(.some((feed: latestFeed, timestamp: latestTimestamp))), file: file, line: line)
    }
    
    func assertThatDeleteHasNoSideEffectsOnEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        deleteCache(from: sut, file: file, line: line)
        
        expect(sut, toRetrieve: .success(.none), file: file, line: line)
    }
    
    func assertThatDeleteDoesNotDeliverErrorOnEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        let deletionError = deleteCache(from: sut, file: file, line: line)
        
        XCTAssertNil(deletionError, "Expected the deletion to complete without errors", file: file, line: line)
    }
    
    func assertThatDeleteDoesNotDeliverErrorOnNonEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        insert(cache: (uniqueImageFeed().local, Date()), to: sut, file: file, line: line)
        
        let deletionError = deleteCache(from: sut, file: file, line: line)
        
        XCTAssertNil(deletionError, "Expected the deletion to complete without errors", file: file, line: line)
    }
    
    func assertThatDeleteLeavesCacheEmptyOnNonEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        insert(cache: (uniqueImageFeed().local, Date()), to: sut, file: file, line: line)
        
        deleteCache(from: sut, file: file, line: line)
        
        expect(sut, toRetrieve: .success(.none), file: file, line: line)
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
        
        wait(for: [exp1, exp2, exp3], timeout: 5.0, file: file, line: line)
        
        XCTAssertEqual(completedOperations, [exp1, exp2, exp3], "Expected side-effects to run serially but operations finished in the wrong order", file: file, line: line)
    }
    
    func expect(_ sut: FeedStore, toRetrieve expectedResult: FeedStore.RetrievalResult, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for cache retrieval")
        
        sut.retrieve { retrievedResult in
            switch (retrievedResult, expectedResult) {
            case (.success(.none), .success(.none)), (.failure, .failure):
                break
                
            case let (.success(.some((retrievedFeed, retrievedTimestamp))), .success(.some((expectedFeed, expectedTimestamp)))):
                XCTAssertEqual(retrievedFeed, expectedFeed, file: file, line: line)
                XCTAssertEqual(retrievedTimestamp, expectedTimestamp, file: file, line: line)
                
            default:
                XCTFail("Expected to retrieve \(expectedResult), got \(retrievedResult) instead", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0, file: file, line: line)
    }
    
    /// Custom wait for test purposes that provides a custom message to the provided file and line params
    func wait(for expectations: [XCTestExpectation], timeout seconds: TimeInterval, file: StaticString = #file, line: UInt = #line) {
        let result = XCTWaiter().wait(for: expectations, timeout: seconds)
        switch result {
        case .timedOut, .incorrectOrder, .invertedFulfillment, .interrupted:
            XCTFail("Got the result \"\(result.description)\" while waiting for expectations [\(expectations.map{"\"\($0)\""}.joined(separator: ","))]", file: file, line: line)
        case .completed: break
        @unknown default: break
        }
    }
    
    func expect(_ sut: FeedStore, toRetrieveTwice expectedResult: FeedStore.RetrievalResult, file: StaticString = #file, line: UInt = #line) {
        expect(sut, toRetrieve: expectedResult, file: file, line: line)
        expect(sut, toRetrieve: expectedResult, file: file, line: line)
    }
    
    @discardableResult
    func insert(cache: (feed: [LocalFeedImage], timestamp: Date), to sut: FeedStore, file: StaticString = #file, line: UInt = #line) -> Error? {
        let exp = expectation(description: "Wait for retrieve result")
        var capturedError: Error?
        
        sut.insert(cache.feed, timestamp: cache.timestamp) { result in
            if case let Result.failure(error) = result { capturedError = error }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0, file: file, line: line)
        return capturedError
    }
    
    @discardableResult
    func deleteCache(from sut: FeedStore, file: StaticString = #file, line: UInt = #line) -> Error? {
        let exp = expectation(description: "Wait for delete completion")
        
        var capturedError: Error?
        sut.deleteCachedFeed { result in
            if case let Result.failure(error) = result { capturedError = error }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0, file: file, line: line)
        return capturedError
    }
}

private extension XCTWaiter.Result {
    var description: String {
        switch self {
        case .completed:
            return "Completed"
        case .timedOut:
            return "Timed Out"
        case .incorrectOrder:
            return "Incorrect Order"
        case .invertedFulfillment:
            return "Inverted Fulfillment"
        case .interrupted:
            return "Interrupted"
        @unknown default:
            return "Unknown"
        }
    }
}
