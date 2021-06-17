//
//  FeedImageDataLoaderWithFallbackCompositeTests.swift
//  EssentialAppTests
//
//  Created by Riccardo Rossi - Home on 17/06/21.
//

import XCTest
import EssentialFeed

final class FeedImageDataLoaderWithFallbackComposite: FeedImageDataLoader {
    private let primary: FeedImageDataLoader
    private let fallback: FeedImageDataLoader
    
    init(primary: FeedImageDataLoader, fallback: FeedImageDataLoader) {
        self.primary = primary
        self.fallback = fallback
    }
    
    private class Task: FeedImageDataLoaderTask {
        func cancel() {}
    }
    
    func loadImageData(from url: URL, completion: @escaping (Completion)) -> FeedImageDataLoaderTask {
        _ = primary.loadImageData(from: url) { [weak self] result in
            switch result {
            case .success:
                break
            
            case .failure:
                _ = self?.fallback.loadImageData(from: url) { _ in }
            }
        }
        return Task()
    }
}

class FeedImageDataLoaderWithFallbackCompositeTests: XCTestCase {
    
    func test_init_doesNotLoadImageData() {
        let (_, primaryLoader, fallbackLoader) = makeSUT()
        
        XCTAssert(primaryLoader.loadedURL.isEmpty, "Expected no loaded URLs in the primary loader")
        XCTAssert(fallbackLoader.loadedURL.isEmpty, "Expected no loaded URLs in the fallback loader")
    }
    
    func test_load_loadsFromPrimaryLoaderFirst() {
        let (sut, primaryLoader, fallbackLoader) = makeSUT()
        let url = anyURL()
        
        _ = sut.loadImageData(from: url) { _ in }
        
        XCTAssertEqual(primaryLoader.loadedURL, [url])
        XCTAssert(fallbackLoader.loadedURL.isEmpty, "Expected no loaded URLs in the fallback loader")
    }
    
    func test_load_loadsFromFallbackLoaderOnPrimaryLoaderFailure() {
        let (sut, primaryLoader, fallbackLoader) = makeSUT()
        let url = anyURL()
        
        _ = sut.loadImageData(from: url) { _ in }
        
        primaryLoader.complete(with: anyNSError())
        
        XCTAssertEqual(primaryLoader.loadedURL, [url])
        XCTAssertEqual(fallbackLoader.loadedURL, [url])
    }
    
    private class ImageLoaderSpy: FeedImageDataLoader {
        var messages = [(url: URL, completion: FeedImageDataLoader.Completion)]()
        var loadedURL: [URL] {
            messages.map { $0.url }
        }
        
        private class Task: FeedImageDataLoaderTask {
            func cancel() {}
        }
        
        func loadImageData(from url: URL, completion: @escaping (Completion)) -> FeedImageDataLoaderTask {
            messages.append((url, completion))
            return Task()
        }
        
        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
    }
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedImageDataLoaderWithFallbackComposite, primaryLoader: ImageLoaderSpy, fallbackLoader: ImageLoaderSpy) {
        let primaryLoader = ImageLoaderSpy()
        let fallbackLoader = ImageLoaderSpy()
        let sut = FeedImageDataLoaderWithFallbackComposite(
            primary: primaryLoader, fallback: fallbackLoader)
        trackForMemoryLeaks(primaryLoader, file: file, line: line)
        trackForMemoryLeaks(fallbackLoader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, primaryLoader, fallbackLoader)
    }
    
    private func anyURL() -> URL {
        return URL(string: "http://any-url.com")!
    }
    
    private func anyNSError() -> NSError {
        return NSError(domain: "any domain", code: 1)
    }
}
