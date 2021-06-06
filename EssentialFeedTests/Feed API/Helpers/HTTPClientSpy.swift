//
//  HTTPClientSpy.swift
//  EssentialFeedTests
//
//  Created by Riccardo Rossi - Home on 06/06/21.
//

import Foundation
import EssentialFeed

final class HTTPClientSpy: HTTPClient {
    private struct Task: HTTPClientTask {
        private var onCancel: () -> Void
        
        init(onCancel: @escaping () -> Void) {
            self.onCancel = onCancel
        }
        
        func cancel() {
            onCancel()
        }
    }
    
    private var messages = [(url: URL, completion: (HTTPClient.Result) -> Void)]()
    
    var requestedURLs: [URL] {
        messages.map { $0.url }
    }
    
    var canceledURLs = [URL]()
    
    func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
        messages.append((url, completion))
        return Task(onCancel: { [weak self] in
            self?.canceledURLs.append(url)
        })
    }
    
    func complete(with error: Error, at index: Int = 0) {
        messages[index].completion(.failure(error))
    }
    
    func complete(withStatusCode code: Int, data: Data, at index: Int = 0) {
        let response = HTTPURLResponse(
            url: requestedURLs[index],
            statusCode: code,
            httpVersion: nil,
            headerFields: nil)!
        
        messages[index].completion(.success((response, data)))
    }
}
