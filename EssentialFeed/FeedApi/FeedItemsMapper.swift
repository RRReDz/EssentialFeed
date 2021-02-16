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
        
        var feeds: [FeedItem] {
            return items.map{$0.feedItem}
        }
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
    
    private static var OK_200: Int { return 200 }
    
    internal static func map(_ data: Data, _ response: HTTPURLResponse) -> RemoteFeedLoader.Result {
        guard response.statusCode == OK_200, let root = try? JSONDecoder().decode(Root.self, from: data) else {
            return .failure(RemoteFeedLoader.Error.invalidData)
        }
        
        return .success(root.feeds)
    }
}
