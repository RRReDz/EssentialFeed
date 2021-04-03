//
//  RemoteFeedItem.swift
//  EssentialFeed
//
//  Created by Riccardo Rossi - Home on 06/03/21.
//

import Foundation

struct RemoteFeedItem: Decodable {
    let id: UUID
    let description: String?
    let location: String?
    let image: URL
}
