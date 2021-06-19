//
//  FeedImageDataLoaderCacheDecoratorTests.swift
//  EssentialAppTests
//
//  Created by Riccardo Rossi - Home on 19/06/21.
//

import XCTest
import EssentialFeed
import EssentialApp

class FeedImageDataLoaderCacheDecoratorTests: XCTestCase, FeedImageDataLoaderTestCase {
    
    func test_init_doesNotLoadURLs() {
        let (_, loader) = makeSUT()
        
        XCTAssertEqual(loader.loadedURL, [], "Expected to load no URLs")
    }
    
    func test_loadImageData_loadsURL() {
        let (sut, loader) = makeSUT()
        let url = anyURL()
        
        _ = sut.loadImageData(from: url) { _ in }
        
        XCTAssertEqual(loader.loadedURL, [url], "Expected to load a URL")
    }
    
    func test_cancelLoadImageData_cancelsURL() {
        let (sut, loader) = makeSUT()
        let url = anyURL()
        
        let task = sut.loadImageData(from: url) { _ in }
        task.cancel()
        
        XCTAssertEqual(loader.canceledURLs, [url], "Expected to cancel a URL")
    }

    func test_loadImageData_deliversFeedOnLoaderSuccess() {
        let data = anyData()
        let (sut, loader) = makeSUT()
        
        expect(sut, toCompleteWith: .success(data), when: {
            loader.complete(with: data)
        })
    }
    
    func test_loadImageData_deliversFeedOnLoaderFailure() {
        let (sut, loader) = makeSUT()
        
        expect(sut, toCompleteWith: .failure(anyNSError()), when: {
            loader.complete(with: anyNSError())
        })
    }
    
    func test_loadImageData_cachesLoadedFeedOnLoaderSuccess() {
        let cache = FeedImageCacheSpy()
        let (sut, loader) = makeSUT(cache: cache)
        let data = anyData()
        let url = anyURL()
        
        _ = sut.loadImageData(from: url) { _ in }
        
        loader.complete(with: data)
        
        XCTAssertEqual(cache.messages, [.save(data, for: url)])
    }
    
    func test_loadImageData_doesNotCacheImageDataOnLoaderFailure() {
        let cache = FeedImageCacheSpy()
        let (sut, loader) = makeSUT(cache: cache)
        let url = anyURL()
        
        _ = sut.loadImageData(from: url) { _ in }
        
        loader.complete(with: anyNSError())
        
        XCTAssertEqual(cache.messages, [])
    }
    
    private func makeSUT(cache: FeedImageCacheSpy = .init(), file: StaticString = #file, line: UInt = #line) -> (sut: FeedImageDataLoaderCacheDecorator, loader: FeedImageDataLoaderSpy) {
        let loader = FeedImageDataLoaderSpy()
        let sut = FeedImageDataLoaderCacheDecorator(decoratee: loader, cache: cache)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(cache, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, loader)
    }
    
    private class FeedImageCacheSpy: FeedImageDataCache {
        enum Message: Equatable {
            case save(Data, for: URL)
        }
        
        var messages = [Message]()
        
        func save(data: Data, for url: URL, completion: @escaping (FeedImageDataCache.Result) -> Void) {
            messages.append(.save(data, for: url))
        }
    }

}
