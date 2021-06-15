//
//  FeedImageViewModel.swift
//  EssentialFeed
//
//  Created by Riccardo Rossi - Home on 30/05/21.
//

import Foundation

public struct FeedImageViewModel<Image> {
    public let location: String?
    public let description: String?
    public let image: Image?
    public let isLoading: Bool
    public let retryLoading: Bool
}
