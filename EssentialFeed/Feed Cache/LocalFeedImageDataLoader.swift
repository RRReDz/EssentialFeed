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
}

extension LocalFeedImageDataLoader {
    public typealias LoadResult = FeedImageDataLoader.Result
    
    public enum LoadError: Swift.Error {
        case failed
        case notFound
    }
    
    private class LoadImageDataTask: FeedImageDataLoaderTask {
        private var completion: FeedImageDataLoader.Completion?
        
        init(_ completion: @escaping FeedImageDataLoader.Completion) {
            self.completion = completion
        }
        
        func cancel() {
            completion = nil
        }
        
        func complete(with result: LoadResult) {
            completion?(result)
        }
    }
    
    public func loadImageData(from url: URL, completion: @escaping FeedImageDataLoader.Completion) -> FeedImageDataLoaderTask {
        let task = LoadImageDataTask(completion)
        store.retrieve(dataFor: url) { [weak self] result in
            guard self != nil else { return }
            task.complete(with: result
                    .mapError { _ in LoadError.failed }
                    .flatMap { $0.map { .success($0) } ?? .failure(LoadError.notFound) })
        }
        return task
    }
}

extension LocalFeedImageDataLoader: FeedImageDataCache {
    public typealias SaveResult = FeedImageDataCache.Result

    public enum SaveError: Error {
        case failed
    }
    
    public func save(data: Data, for url: URL, completion: @escaping (SaveResult) -> Void) {
        store.insert(data, for: url) { [weak self] in
            guard self != nil else { return }
            completion($0.mapError { _ in SaveError.failed })
        }
    }
}
