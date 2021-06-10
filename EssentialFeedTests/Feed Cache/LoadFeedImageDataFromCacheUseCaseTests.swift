//
//  LoadFeedImageDataFromCacheUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Riccardo Rossi - Home on 09/06/21.
//

import XCTest
import EssentialFeed

class LoadFeedImageDataFromCacheUseCaseTests: XCTestCase {

    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.messages, [])
    }
    
    func test_loadImageData_requestsStoreDataRetrieval() {
        let (sut, store) = makeSUT()
        let url = anyURL()
        
        _ = sut.loadImageData(from: url) { _ in }
        
        XCTAssertEqual(store.messages, [.retrieve(dataFor: url)])
    }
    
    func test_loadImageData_failsOnStoreError() {
        let (sut, store) = makeSUT()
        
        expect(sut, toCompleteWith: failed(), when: {
            store.completeRetrieval(with: anyNSError())
        })
    }
    
    func test_loadImageData_deliversNotFoundErrorOnNoneImageData() {
        let (sut, store) = makeSUT()
        
        expect(sut, toCompleteWith: notFound(), when: {
            store.completeRetrieval(with: .none)
        })
    }
    
    func test_loadImageData_deliversStoredDataOnFoundImageData() {
        let (sut, store) = makeSUT()
        let data = anyData()
        
        expect(sut, toCompleteWith: .success(anyData()), when: {
            store.completeRetrieval(with: data)
        })
    }
    
    func test_loadImageData_doesNotDeliverResultOnTaskCancel() {
        let (sut, store) = makeSUT()
        
        var capturedResult: FeedImageDataLoader.Result?
        let task = sut.loadImageData(from: anyURL()) { capturedResult = $0 }
        
        task.cancel()
        
        store.completeRetrieval(with: anyData())
        store.completeRetrieval(with: anyNSError())
        store.completeRetrieval(with: nil)
        
        XCTAssertNil(capturedResult, "Expected no result captured after canceling task")
    }
    
    func test_loadImageData_doesNotDeliverResultAfterInstanceHasBeenDeallocated() {
        let store = FeedImageDataStoreSpy()
        var sut: LocalFeedImageDataLoader? = LocalFeedImageDataLoader(store: store)
        
        var capturedResult: FeedImageDataLoader.Result?
        _ = sut?.loadImageData(from: anyURL()) { capturedResult = $0 }
        sut = nil
        
        store.completeRetrieval(with: anyData())
        
        XCTAssertNil(capturedResult, "Expected no result capture after instance has been deallocated")
    }
    
    func test_saveImageData_requestsImageDataInsertion() {
        let (sut, store) = makeSUT()
        let url = anyURL()
        let data = anyData()
        
        sut.save(data: data, for: url)
        
        XCTAssertEqual(store.messages, [.insert(data, for: url)])
    }
    
    private func expect(_ sut: LocalFeedImageDataLoader, toCompleteWith expectedResult: FeedImageDataLoader.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for load image data completion")
        
        _ = sut.loadImageData(from: anyURL()) { receivedResult in
            switch (expectedResult, receivedResult) {
            
            case let (.success(expectedData), .success(retrievedData)):
                XCTAssertEqual(expectedData, retrievedData, file: file, line: line)
            
            case let (.failure(expectedError as LocalFeedImageDataLoader.LoadError),
                    .failure(receivedError as LocalFeedImageDataLoader.LoadError)):
                XCTAssertEqual(expectedError, receivedError, file: file, line: line)
                
            default:
                XCTFail("Expected result \(expectedResult), got \(receivedResult) instead", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        action()
        wait(for: [exp], timeout: 1.0)
    }
    
    private func failed() -> FeedImageDataLoader.Result {
        return .failure(LocalFeedImageDataLoader.LoadError.failed)
    }
    
    private func notFound() -> FeedImageDataLoader.Result {
        return .failure(LocalFeedImageDataLoader.LoadError.notFound)
    }
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedImageDataLoader, store: FeedImageDataStoreSpy) {
        let store = FeedImageDataStoreSpy()
        let sut = LocalFeedImageDataLoader(store: store)
        trackForMemoryLeaks(store)
        trackForMemoryLeaks(sut)
        return (sut, store)
    }
}
