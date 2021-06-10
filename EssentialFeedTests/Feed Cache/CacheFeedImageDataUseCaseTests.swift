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
        
        sut.save(data: data, for: url) { _ in }
        
        XCTAssertEqual(store.messages, [.insert(data, for: url)])
    }
    
    func test_save_failsOnStoreInsertionError() {
        let (sut, store) = makeSUT()
        
        expect(sut, toCompleteWith: failed(), when: {
            store.completeInsertion(with: anyNSError())
        })
    }
    
    func test_save_succeedsOnSuccessfulInsertion() {
        let (sut, store) = makeSUT()
        
        expect(sut, toCompleteWith: .success(()), when: {
            store.completeInsertionSuccessfully()
        })
    }
    
    func test_save_doesNotDeliverResultAfterInstanceHasBeenDeallocated() {
        let store = FeedImageDataStoreSpy()
        var sut: LocalFeedImageDataLoader? = LocalFeedImageDataLoader(store: store)
        
        var capturedResult: LocalFeedImageDataLoader.SaveResult?
        sut?.save(data: anyData(), for: anyURL()) { capturedResult = $0 }
        sut = nil
        
        store.completeInsertion(with: anyNSError())
        store.completeInsertionSuccessfully()
        
        XCTAssertNil(capturedResult, "Expected no result captured after instance has been deallocated")
    }
    
    private func expect(_ sut: LocalFeedImageDataLoader, toCompleteWith expectedResult: LocalFeedImageDataLoader.SaveResult, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        
        let exp = expectation(description: "Wait for save completion")
        
        sut.save(data: anyData(), for: anyURL()) { receivedResult in
            switch (expectedResult, receivedResult) {
            
            case (.failure(let expectedError as LocalFeedImageDataLoader.SaveError), .failure(let receivedError as LocalFeedImageDataLoader.SaveError)):
                XCTAssertEqual(expectedError, receivedError, file: file, line: line)
            
            case (.success, .success):
                break
                
            default:
                XCTFail("Expected \(expectedResult), got \(receivedResult) instead")
            }
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private func failed() -> LocalFeedImageDataLoader.SaveResult {
        return .failure(LocalFeedImageDataLoader.SaveError.failed)
    }
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedImageDataLoader, store: FeedImageDataStoreSpy) {
        let store = FeedImageDataStoreSpy()
        let sut = LocalFeedImageDataLoader(store: store)
        trackForMemoryLeaks(store)
        trackForMemoryLeaks(sut)
        return (sut, store)
    }

}
