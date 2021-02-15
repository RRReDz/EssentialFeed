//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Riccardo Rossi on 11/02/21.
//

import Foundation

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
        client.get(from: url) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let httpResponse, let data):
                completion(self.map(data, httpResponse))
            case .failure(_):
                completion(.failure(.connectivity))
            }
        }
    }
    
    private func map(_ data: Data, _ httpResponse: HTTPURLResponse) -> RemoteFeedLoader.Result {
        do {
            let feedItems = try FeedItemsMapper.map(data, httpResponse)
            return .success(feedItems)
        } catch {
            return .failure(.invalidData)
        }
    }
}
