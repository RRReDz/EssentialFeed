//
//  FeedLoaderWithFallbackComposite.swift
//  EssentialApp
//
//  Created by Riccardo Rossi - Home on 16/06/21.
//

import Foundation
import EssentialFeed

public final class FeedLoaderWithFallbackComposite: FeedLoader {
    private let primary: FeedLoader
    private let fallback: FeedLoader
    
    public init(primary: FeedLoader, fallback: FeedLoader) {
        self.primary = primary
        self.fallback = fallback
    }
    
    public func load(completion: @escaping (Result<[FeedImage], Error>) -> Void) {
        primary.load { [weak self] result in
            switch result {
            case let .success(feed):
                completion(.success(feed))
            case .failure:
                self?.fallback.load(completion: completion)
            }
        }
    }
}
