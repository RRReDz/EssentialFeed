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
    
    private class TaskWrapper: FeedImageDataLoaderTask {
        private let wrapped: FeedImageDataLoaderTask
        
        init(wrapped: FeedImageDataLoaderTask) {
            self.wrapped = wrapped
        }

        func cancel() {
            wrapped.cancel()
        }
    }
    
    func loadImageData(from url: URL, completion: @escaping (Completion)) -> FeedImageDataLoaderTask {
        let primaryTask = primary.loadImageData(from: url) { [weak self] result in
            switch result {
            case .success:
                break
            
            case .failure:
                _ = self?.fallback.loadImageData(from: url) { _ in }
            }
        }
        return TaskWrapper(wrapped: primaryTask)
    }
}

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
        
        XCTAssertEqual(primaryLoader.canceledURLs, [url], "Expected the URL as canceled in the primary loader")
        XCTAssertEqual(fallbackLoader.canceledURLs, [], "Expected no canceled URLs in the fallback loader")
    }
    
    
    
    private class ImageLoaderSpy: FeedImageDataLoader {
        var messages = [(url: URL, completion: FeedImageDataLoader.Completion)]()
        var loadedURL: [URL] {
            messages.map { $0.url }
        }
        var canceledURLs = [URL]()
        
        private class Task: FeedImageDataLoaderTask {
            private let onCancel: () -> Void

            init(onCancel: @escaping () -> Void) {
                self.onCancel = onCancel
            }
            
            func cancel() {
                onCancel()
            }
        }
        
        func loadImageData(from url: URL, completion: @escaping (Completion)) -> FeedImageDataLoaderTask {
            messages.append((url, completion))
            return Task(onCancel: { [weak self] in
                self?.canceledURLs.append(url)
            })
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
