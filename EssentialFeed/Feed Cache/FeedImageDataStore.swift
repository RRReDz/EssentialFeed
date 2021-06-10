//
//  FeedImageDataStore.swift
//  EssentialFeed
//
//  Created by Riccardo Rossi - Home on 10/06/21.
//

import Foundation

public protocol FeedImageDataStore {
    typealias RetrievalResult = Swift.Result<Data?, Error>
    
    func retrieve(dataFor url: URL, completion: @escaping (RetrievalResult) -> Void)
    func insert(_ data: Data, for url: URL)
}
