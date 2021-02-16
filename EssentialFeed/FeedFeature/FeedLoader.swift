//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Riccardo Rossi on 10/02/21.
//

import Foundation

public enum LoadFeedResult {
    case success([FeedItem])
    case failure(Error)
}

public protocol FeedLoader {
    associatedtype Error: Swift.Error
    func load(completion: @escaping (LoadFeedResult) -> Void)
}
