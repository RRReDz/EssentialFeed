//
//  LocalFeedImageDataLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Riccardo Rossi - Home on 09/06/21.
//

import XCTest
import EssentialFeed

protocol FeedImageDataStore {
    typealias Result = Swift.Result<Data?, Error>
    
    func retrieve(dataFrom url: URL, completion: @escaping (FeedImageDataStore.Result) -> Void)
}

final class LocalFeedImageDataLoader {
    private let store: FeedImageDataStore
    
    init(store: FeedImageDataStore) {
        self.store = store
    }
    
    enum Error: Swift.Error {
        case failed
        case notFound
    }
    
    private class Task: FeedImageDataLoaderTask {
        private var completion: FeedImageDataLoader.Completion?
        
        init(_ completion: @escaping FeedImageDataLoader.Completion) {
            self.completion = completion
        }
        
        func cancel() {
            completion = nil
        }
        
        func complete(with result: FeedImageDataLoader.Result) {
            completion?(result)
        }
    }
    
    func loadImageData(from url: URL, completion: @escaping FeedImageDataLoader.Completion) -> FeedImageDataLoaderTask {
        let task = Task(completion)
        store.retrieve(dataFrom: url) { [weak self] result in
            guard self != nil else { return }
            task.complete(with: result
                    .mapError { _ in Error.failed }
                    .flatMap { $0.map { .success($0) } ?? .failure(Error.notFound) })
        }
        return task
    }
}

class LocalFeedImageDataLoaderTests: XCTestCase {

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
            store.complete(with: anyNSError())
        })
    }
    
    func test_loadImageData_deliversNotFoundErrorOnNoneImageData() {
        let (sut, store) = makeSUT()
        
        expect(sut, toCompleteWith: notFound(), when: {
            store.complete(with: .none)
        })
    }
    
    func test_loadImageData_deliversStoredDataOnFoundImageData() {
        let (sut, store) = makeSUT()
        let data = anyData()
        
        expect(sut, toCompleteWith: .success(anyData()), when: {
            store.complete(with: data)
        })
    }
    
    func test_loadImageData_doesNotDeliverResultOnTaskCancel() {
        let (sut, store) = makeSUT()
        
        var capturedResult: FeedImageDataLoader.Result?
        let task = sut.loadImageData(from: anyURL()) { capturedResult = $0 }
        
        task.cancel()
        
        store.complete(with: anyData())
        store.complete(with: anyNSError())
        store.complete(with: nil)
        
        XCTAssertNil(capturedResult, "Expected no result captured after canceling task")
    }
    
    func test_loadImageData_doesNotDeliverResultAfterInstanceHasBeenDeallocated() {
        let store = FeedStoreSpy()
        var sut: LocalFeedImageDataLoader? = LocalFeedImageDataLoader(store: store)
        
        var capturedResult: FeedImageDataLoader.Result?
        _ = sut?.loadImageData(from: anyURL()) { capturedResult = $0 }
        sut = nil
        
        store.complete(with: anyData())
        
        XCTAssertNil(capturedResult, "Expected no result capture after instance has been deallocated")
    }
    
    private func expect(_ sut: LocalFeedImageDataLoader, toCompleteWith expectedResult: FeedImageDataLoader.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for load image data completion")
        
        _ = sut.loadImageData(from: anyURL()) { receivedResult in
            switch (expectedResult, receivedResult) {
            
            case let (.success(expectedData), .success(retrievedData)):
                XCTAssertEqual(expectedData, retrievedData, file: file, line: line)
            
            case let (.failure(expectedError as LocalFeedImageDataLoader.Error),
                    .failure(receivedError as LocalFeedImageDataLoader.Error)):
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
        return .failure(LocalFeedImageDataLoader.Error.failed)
    }
    
    private func notFound() -> FeedImageDataLoader.Result {
        return .failure(LocalFeedImageDataLoader.Error.notFound)
    }
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedImageDataLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedImageDataLoader(store: store)
        trackForMemoryLeaks(store)
        trackForMemoryLeaks(sut)
        return (sut, store)
    }
    
    private final class FeedStoreSpy: FeedImageDataStore {
        enum Message: Equatable {
            case retrieve(dataFor: URL)
        }
        
        var messages = [Message]()
        var completions = [(FeedImageDataStore.Result) -> Void]()

        func retrieve(dataFrom url: URL, completion: @escaping (FeedImageDataStore.Result) -> Void) {
            messages.append(.retrieve(dataFor: url))
            completions.append(completion)
        }
        
        func complete(with error: Error, index: Int = 0) {
            completions[index](.failure(error))
        }
        
        func complete(with data: Data?, index: Int = 0) {
            completions[index](.success(data))
        }
    }
}
