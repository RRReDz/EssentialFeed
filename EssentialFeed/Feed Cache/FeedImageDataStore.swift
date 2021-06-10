//
//  FeedImageDataStore.swift
//  EssentialFeed
//
//  Created by Riccardo Rossi - Home on 10/06/21.
//

import Foundation

public protocol FeedImageDataStore {
    typealias RetrievalResult = Result<Data?, Error>
    typealias InsertionResult = Result<Void, Error>
    
    func retrieve(dataFor url: URL, completion: @escaping (RetrievalResult) -> Void)
    func insert(_ data: Data, for url: URL, completion: @escaping (InsertionResult) -> Void)
}
