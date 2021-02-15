//
//  FeedItemsMapper.swift
//  EssentialFeed
//
//  Created by Riccardo Rossi on 15/02/21.
//

import Foundation

internal class FeedItemsMapper {
    internal struct Root: Decodable {
        let items: [Item]
    }

    internal struct Item: Decodable {
        let id: UUID
        let description: String?
        let location: String?
        let image: URL
        
        var feedItem: FeedItem {
            return FeedItem(
                id: id,
                description: description,
                location: location,
                imageURL: image
            )
        }
    }
    
    internal static func map(_ data: Data, _ response: HTTPURLResponse) throws -> [FeedItem] {
        guard response.statusCode == 200 else {
            throw RemoteFeedLoader.Error.invalidData
        }
        
        let feedsRoot = try JSONDecoder().decode(Root.self, from: data)
        return feedsRoot.items.map{$0.feedItem}
    }
}
