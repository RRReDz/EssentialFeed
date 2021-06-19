//
//  FeedCache.swift
//  EssentialFeed
//
//  Created by Riccardo Rossi - Home on 19/06/21.
//

import Foundation

public protocol FeedCache {
    typealias Result = Swift.Result<Void, Error>
    func save(_ feed: [FeedImage], completion: @escaping (Result) -> Void)
}
