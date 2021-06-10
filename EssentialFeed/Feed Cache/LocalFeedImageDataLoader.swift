//
//  LocalFeedImageDataLoader.swift
//  EssentialFeed
//
//  Created by Riccardo Rossi - Home on 10/06/21.
//

import Foundation

public final class LocalFeedImageDataLoader {
    private let store: FeedImageDataStore
    
    public init(store: FeedImageDataStore) {
        self.store = store
    }
    
    public enum Error: Swift.Error {
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
    
    public func loadImageData(from url: URL, completion: @escaping FeedImageDataLoader.Completion) -> FeedImageDataLoaderTask {
        let task = Task(completion)
        store.retrieve(dataFor: url) { [weak self] result in
            guard self != nil else { return }
            task.complete(with: result
                    .mapError { _ in Error.failed }
                    .flatMap { $0.map { .success($0) } ?? .failure(Error.notFound) })
        }
        return task
    }
    
    public func saveImageData(_ data: Data, for url: URL) {
        store.insert(data, for: url)
    }
}
