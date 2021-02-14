//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Riccardo Rossi on 11/02/21.
//

import Foundation

public enum HTTPClientResponse {
    case success(HTTPURLResponse, Data)
    case failure(Error)
}

public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (HTTPClientResponse) -> Void)
}

public final class RemoteFeedLoader {
    private let client: HTTPClient
    private let url: URL
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public enum Result: Equatable {
        case success([FeedItem])
        case failure(RemoteFeedLoader.Error)
    }
    
    public init(client: HTTPClient, url: URL) {
        self.client = client
        self.url = url
    }
    
    public func load(completion: @escaping (RemoteFeedLoader.Result) -> Void) {
        client.get(from: url) { result in
            switch result {
            case .success(_, let data):
                if let feedsRoot = try? JSONDecoder().decode(Root.self, from: data) {
                    completion(.success(feedsRoot.items))
                } else {
                    completion(.failure(.invalidData))
                }
            case .failure(_):
                completion(.failure(.connectivity))
            }
        }
    }
    
    private struct Root: Decodable {
        let items: [FeedItem]
    }
}
