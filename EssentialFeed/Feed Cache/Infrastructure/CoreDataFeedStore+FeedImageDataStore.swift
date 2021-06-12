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
            completion(Result {
                let matchingFeed = try ManagedFeedImage.first(with: url, in: context)
                return matchingFeed?.data
            })
        }
    }
    
    public func insert(_ data: Data, for url: URL, completion: @escaping (FeedImageDataStore.InsertionResult) -> Void) {
        perform { context in
            completion(Result {
                let matchingFeed = try ManagedFeedImage.first(with: url, in: context)
                matchingFeed?.data = data
                
                try context.save()
                return Void()
            })
        }
    }
}
