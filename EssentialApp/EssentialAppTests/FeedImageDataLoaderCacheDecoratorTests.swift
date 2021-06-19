//
//  FeedImageDataLoaderCacheDecoratorTests.swift
//  EssentialAppTests
//
//  Created by Riccardo Rossi - Home on 19/06/21.
//

import XCTest
import EssentialFeed

protocol FeedImageDataCache {
    typealias Result = Swift.Result<Void, Error>
    func save(data: Data, for url: URL, completion: @escaping (Result) -> Void)
}

final class FeedImageDataLoaderCacheDecorator: FeedImageDataLoader {
    private let decoratee: FeedImageDataLoader
    private let cache: FeedImageDataCache
    
    init(decoratee: FeedImageDataLoader, cache: FeedImageDataCache) {
        self.decoratee = decoratee
        self.cache = cache
    }
    
    func loadImageData(from url: URL, completion: @escaping (Completion)) -> FeedImageDataLoaderTask {
        return decoratee.loadImageData(from: url) { [weak self] result in
            self?.cache.save(data: (try? result.get()) ?? Data(), for: url) { _ in }
            completion(result)
        }
    }
}

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
