//
//  FeedViewControllerTests+LoaderSpy.swift
//  EssentialFeediOSTests
//
//  Created by Riccardo Rossi - Home on 12/04/21.
//

import Foundation
import EssentialFeed
import EssentialFeediOS

final class LoaderSpy: FeedLoader, FeedImageDataLoader {
    
    // MARK: - FeedLoader
    
    private var feedRequests: [(Result<[FeedImage], Error>) -> Void] = []
    
    var loadFeedCallCount: Int {
        return feedRequests.count
    }
    
    func load(completion: @escaping (Result<[FeedImage], Error>) -> Void) {
        feedRequests.append(completion)
    }
    
    func completeFeedLoading(with feed: [FeedImage] = [], at index: Int = 0) {
        feedRequests[index](.success(feed))
    }
    
    func completeFeedLoadingWithError(at index: Int) {
        let error = NSError(domain: "Foo Error", code: 1)
        feedRequests[index](.failure(error))
    }
    
    func completeImageLoading(with imageData: Data = Data(), at index: Int) {
        imageRequests[index].completion(.success(imageData))
    }
    
    func completeImageLoadingWithError(at index: Int) {
        let error = NSError(domain: "Foo Error", code: 1)
        imageRequests[index].completion(.failure(error))
    }
    
    // MARK: - FeedImageDataLoader
    
    private(set) var cancelledImageURLs: [URL] = []
    private(set) var imageRequests: [(url: URL, completion: (Result<Data, Error>) -> Void)] = []
    var loadedImageURLs: [URL] {
        return imageRequests.map { $0.url }
    }
    
    private struct TaskSpy: FeedImageDataLoaderTask {
        let onCancel: () -> Void
        
        func cancel() {
            onCancel()
        }
    }
    
    func loadImageData(from url: URL, completion: @escaping (Result<Data, Error>) -> Void) -> FeedImageDataLoaderTask {
        imageRequests.append((url, completion))
        return TaskSpy { [weak self] in
            self?.cancelledImageURLs.append(url)
        }
    }
    
}
