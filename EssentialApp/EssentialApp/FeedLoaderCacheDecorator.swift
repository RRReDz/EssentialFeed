//
//  FeedLoaderCacheDecorator.swift
//  EssentialApp
//
//  Created by Riccardo Rossi - Home on 19/06/21.
//

import Foundation
import EssentialFeed

public final class FeedLoaderCacheDecorator: FeedLoader {
    private let decoratee: FeedLoader
    private let cache: FeedCache
    
    public init(decoratee: FeedLoader, cache: FeedCache) {
        self.decoratee = decoratee
        self.cache = cache
    }
    
    public func load(completion: @escaping (Result<[FeedImage], Error>) -> Void) {
        decoratee.load { [weak self] result in
            completion(
                result.map { feed in
                    self?.cache.save(feed) { _ in }
                    return feed
                }
            )
        }
    }
}
