//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Riccardo Rossi on 10/02/21.
//

import Foundation

enum LoadFeedResult {
    case success([FeedItem])
    case failure(Error)
}

protocol FeedLoader {
    func load(completion: @escaping (LoadFeedResult) -> Void)
}
