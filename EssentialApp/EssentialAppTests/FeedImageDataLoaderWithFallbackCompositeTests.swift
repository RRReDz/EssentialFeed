//
//  FeedImageDataLoaderWithFallbackCompositeTests.swift
//  EssentialAppTests
//
//  Created by Riccardo Rossi - Home on 17/06/21.
//

import XCTest
import EssentialFeed
import EssentialApp

class FeedImageDataLoaderWithFallbackCompositeTests: XCTestCase {
    
    func test_init_doesNotLoadImageData() {
        let (_, primaryLoader, fallbackLoader) = makeSUT()
        
        XCTAssert(primaryLoader.loadedURL.isEmpty, "Expected no loaded URLs in the primary loader")
        XCTAssert(fallbackLoader.loadedURL.isEmpty, "Expected no loaded URLs in the fallback loader")
    }
    
    func test_loadImageData_loadsFromPrimaryLoaderFirst() {
        let (sut, primaryLoader, fallbackLoader) = makeSUT()
        let url = anyURL()
        
        _ = sut.loadImageData(from: url) { _ in }
        
        XCTAssertEqual(primaryLoader.loadedURL, [url], "Expected a loaded URL in the primary loader")
        XCTAssert(fallbackLoader.loadedURL.isEmpty, "Expected no loaded URLs in the fallback loader")
    }
    
    func test_loadImageData_loadsFromFallbackLoaderOnPrimaryLoaderFailure() {
        let (sut, primaryLoader, fallbackLoader) = makeSUT()
        
        let url = anyURL()
        
        _ = sut.loadImageData(from: url) { _ in }
        
        primaryLoader.complete(with: anyNSError())
        
        XCTAssertEqual(primaryLoader.loadedURL, [url], "Expected a loaded URL in the primary loader")
        XCTAssertEqual(fallbackLoader.loadedURL, [url], "Expected a loaded URL in the fallback loader")
    }
    
    func test_loadImageData_cancelsPrimaryLoaderTaskOnCancel() {
        let (sut, primaryLoader, fallbackLoader) = makeSUT()
        let url = anyURL()
        
        let task = sut.loadImageData(from: url) { _ in }
        
        task.cancel()
        
        XCTAssertEqual(primaryLoader.canceledURLs, [url], "Expected a canceled URL in the primary loader")
        XCTAssertEqual(fallbackLoader.canceledURLs, [], "Expected no canceled URLs in the fallback loader")
    }
    
    func test_loadImageData_cancelsFallbackLoaderTaskOnCancelAfterAPrimaryLoaderFailure() {
        let (sut, primaryLoader, fallbackLoader) = makeSUT()
        let url = anyURL()
        
        let task = sut.loadImageData(from: url) { _ in }
        
        primaryLoader.complete(with: anyNSError())
        
        task.cancel()
        
        XCTAssert(primaryLoader.canceledURLs.isEmpty, "Expected no canceled URLs in the primary loader")
        XCTAssertEqual(fallbackLoader.canceledURLs, [url], "Expected a canceled URL in the fallback loader")
    }
    
    func test_loadImageData_deliversPrimaryDataOnPrimaryLoaderSuccess() {
        let (sut, primaryLoader, _) = makeSUT()
        let data = anyData()
        
        expect(sut, toCompleteWith: .success(data), when: {
            primaryLoader.complete(with: data)
        })
    }
    
    func test_loadImageData_deliversFallbackDataOnFallbackLoaderSuccess() {
        let (sut, primaryLoader, fallbackLoader) = makeSUT()
        let fallbackData = anyData()
        
        expect(sut, toCompleteWith: .success(fallbackData), when: {
            primaryLoader.complete(with: anyNSError())
            fallbackLoader.complete(with: fallbackData)
        })
    }
    
    func test_loadImageData_deliversErrorOnBothPrimaryAndFallbackLoaderError() {
        let (sut, primaryLoader, fallbackLoader) = makeSUT()
        
        expect(sut, toCompleteWith: .failure(anyNSError()), when: {
            primaryLoader.complete(with: anyNSError())
            fallbackLoader.complete(with: anyNSError())
        })
    }
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedImageDataLoaderWithFallbackComposite, primaryLoader: FeedImageDataLoaderSpy, fallbackLoader: FeedImageDataLoaderSpy) {
        let primaryLoader = FeedImageDataLoaderSpy()
        let fallbackLoader = FeedImageDataLoaderSpy()
        let sut = FeedImageDataLoaderWithFallbackComposite(
            primary: primaryLoader, fallback: fallbackLoader)
        trackForMemoryLeaks(primaryLoader, file: file, line: line)
        trackForMemoryLeaks(fallbackLoader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, primaryLoader, fallbackLoader)
    }
    
    private func expect(_ sut: FeedImageDataLoader, toCompleteWith expectedResult: FeedImageDataLoader.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for load completion")
        
        _ = sut.loadImageData(from: anyURL()) { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedFeed), .success(expectedFeed)):
                XCTAssertEqual(receivedFeed, expectedFeed, file: file, line: line)
                
            case (.failure, .failure):
                break
                
            default:
                XCTFail("Expected \(expectedResult), got \(receivedResult) instead", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
}
