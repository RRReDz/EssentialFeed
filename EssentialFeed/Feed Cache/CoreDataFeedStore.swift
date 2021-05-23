//
//  CoreDataFeedStore.swift
//  EssentialFeed
//
//  Created by Riccardo Rossi - Home on 23/05/21.
//

import Foundation

public final class CoreDataFeedStore: FeedStore {
    public init() {}
    
    public func retrieve(completion: @escaping RetrievalCompletion) {
        completion(.success(nil))
    }
    
    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {}
    
    public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {}
}
