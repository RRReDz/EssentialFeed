//
//  FeedItem.swift
//  EssentialFeed
//
//  Created by Riccardo Rossi on 10/02/21.
//

import Foundation

public struct FeedItem: Equatable {
    let id: UUID
    let description: String?
    let location: String?
    let image: URL
}

