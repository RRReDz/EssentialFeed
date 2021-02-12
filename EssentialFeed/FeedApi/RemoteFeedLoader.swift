//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Riccardo Rossi on 11/02/21.
//

import Foundation

public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (Error) -> Void)
}

public final class RemoteFeedLoader {
    private let client: HTTPClient
    private let url: URL
    
    public enum Error: Swift.Error {
        case connectivity
    }
    
    public init(client: HTTPClient, url: URL) {
        self.client = client
        self.url = url
    }
    
    public func load(completion: @escaping (RemoteFeedLoader.Error) -> Void) {
        client.get(from: url) { _ in
            completion(.connectivity)
        }
    }
}
