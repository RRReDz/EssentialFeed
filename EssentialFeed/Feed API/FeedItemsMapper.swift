//
//  FeedItemsMapper.swift
//  EssentialFeed
//
//  Created by Riccardo Rossi on 15/02/21.
//

import Foundation

class FeedItemsMapper {
    struct Root: Decodable {
        let items: [RemoteFeedItem]
    }
    
    static func map(_ data: Data, _ response: HTTPURLResponse) throws -> [RemoteFeedItem] {
        guard response.isOk, let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw RemoteFeedLoader.Error.invalidData
        }
        
        return root.items
    }
}
