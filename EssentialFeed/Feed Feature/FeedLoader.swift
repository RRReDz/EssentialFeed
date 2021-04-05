//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Riccardo Rossi on 10/02/21.
//

import Foundation

public protocol FeedLoader {
    typealias Result = Swift.Result<[FeedImage], Error>
    
    func load(completion: @escaping (FeedLoader.Result) -> Void)
}
