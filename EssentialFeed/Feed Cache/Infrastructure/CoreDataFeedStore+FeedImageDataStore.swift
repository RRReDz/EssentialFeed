//
//  CoreDataFeedStore+FeedImageDataStore.swift
//  EssentialFeed
//
//  Created by Riccardo Rossi - Home on 12/06/21.
//

import Foundation

extension CoreDataFeedStore: FeedImageDataStore {
    public func retrieve(dataFor url: URL, completion: @escaping (FeedImageDataStore.RetrievalResult) -> Void) {
        perform { context in
            do {
                let managedCache = try ManagedCache.find(in: context)
                let matchingFeed = managedCache?.feed.compactMap { $0 as? ManagedFeedImage }.first(where: { $0.url == url })
                completion(.success(matchingFeed?.data))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    public func insert(_ data: Data, for url: URL, completion: @escaping (FeedImageDataStore.InsertionResult) -> Void) {
        perform { context in
            do {
                let managedCache = try ManagedCache.find(in: context)
                let matchingFeed = managedCache?.feed.compactMap { $0 as? ManagedFeedImage }.first(where: { $0.url == url })
                matchingFeed?.data = data
                try context.save()
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }
}
