//
//  FeedImageDataCache.swift
//  EssentialFeed
//
//  Created by Riccardo Rossi - Home on 19/06/21.
//

import Foundation

public protocol FeedImageDataCache {
    typealias Result = Swift.Result<Void, Error>
    func save(data: Data, for url: URL, completion: @escaping (Result) -> Void)
}
