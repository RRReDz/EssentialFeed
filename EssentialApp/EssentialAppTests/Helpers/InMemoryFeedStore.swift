//
//  InMemoryFeedStore.swift
//  EssentialAppTests
//
//  Created by Riccardo Rossi - Home on 26/06/21.
//

import Foundation
import EssentialFeed

class InMemoryFeedStore: FeedStore, FeedImageDataStore {
    typealias CachedFeed = (feed: [LocalFeedImage], timestamp: Date)
    
    private init(cachedFeed: CachedFeed? = nil) {
        self.cachedFeed = cachedFeed
    }
    
    private(set) var cachedFeed: CachedFeed?
    private var cachedFeedImageData = [URL : Data]()
    
    func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        cachedFeed = nil
        completion(.success(()))
    }
    
    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        cachedFeed = CachedFeed(feed: feed, timestamp: timestamp)
        completion(.success(()))
    }
    
    func retrieve(completion: @escaping RetrievalCompletion) {
        completion(.success(cachedFeed.map { ($0.feed, $0.timestamp) }))
    }
    
    func retrieve(dataFor url: URL, completion: @escaping (FeedImageDataStore.RetrievalResult) -> Void) {
        completion(.success(cachedFeedImageData[url]))
    }
    
    func insert(_ data: Data, for url: URL, completion: @escaping (InsertionResult) -> Void) {
        cachedFeedImageData[url] = data
    }
    
    static var empty: InMemoryFeedStore {
        return InMemoryFeedStore()
    }
    
    static var withExpiredFeedCache: InMemoryFeedStore {
        return InMemoryFeedStore(cachedFeed: (feed: [], timestamp: Date.distantPast))
    }
    
    static var withNonExpiredFeedCache: InMemoryFeedStore {
        return InMemoryFeedStore(cachedFeed: (feed: [], timestamp: Date()))
    }
}
