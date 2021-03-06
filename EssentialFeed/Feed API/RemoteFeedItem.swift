//
//  RemoteFeedItem.swift
//  EssentialFeed
//
//  Created by Riccardo Rossi - Home on 06/03/21.
//

import Foundation

internal struct RemoteFeedItem: Decodable {
    internal let id: UUID
    internal let description: String?
    internal let location: String?
    internal let image: URL
}
