//
//  FeedImageDataStore.swift
//  EssentialFeed
//
//  Created by Riccardo Rossi - Home on 10/06/21.
//

import Foundation

public protocol FeedImageDataStore {
    typealias Result = Swift.Result<Data?, Error>
    
    func retrieve(dataFrom url: URL, completion: @escaping (FeedImageDataStore.Result) -> Void)
    func insert(_ data: Data, for url: URL)
}
