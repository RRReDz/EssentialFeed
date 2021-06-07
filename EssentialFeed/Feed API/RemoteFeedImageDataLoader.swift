//
//  RemoteFeedImageDataLoader.swift
//  EssentialFeed
//
//  Created by Riccardo Rossi - Home on 06/06/21.
//

import Foundation

public final class RemoteFeedImageDataLoader: FeedImageDataLoader {
    private let client: HTTPClient
    
    public init(client: HTTPClient) {
        self.client = client
    }
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    private final class HTTPClientTaskWrapper: FeedImageDataLoaderTask {
        var wrapped: HTTPClientTask?
        private(set) var canceled: Bool = false
        
        func cancel() {
            canceled = true
            wrapped?.cancel()
        }
    }
    
    public func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Completion)) -> FeedImageDataLoaderTask {
        let task = HTTPClientTaskWrapper()
        task.wrapped = client.get(from: url) { [weak self] result in
            guard self != nil, !task.canceled else { return }
            completion(result
                .mapError { _ in Error.connectivity }
                .flatMap { (response, data) in
                    let isValidResponse = response.isOk && !data.isEmpty
                    return isValidResponse ? .success(data) : .failure(Error.invalidData)
                }
            )
        }
        return task
    }
}
