//
//  FeedImageDataLoaderSpy.swift
//  EssentialAppTests
//
//  Created by Riccardo Rossi - Home on 19/06/21.
//

import Foundation
import EssentialFeed

class FeedImageDataLoaderSpy: FeedImageDataLoader {
    var messages = [(url: URL, completion: FeedImageDataLoader.Completion)]()
    var loadedURL: [URL] {
        messages.map { $0.url }
    }
    var canceledURLs = [URL]()
    
    private class Task: FeedImageDataLoaderTask {
        private let onCancel: () -> Void

        init(onCancel: @escaping () -> Void) {
            self.onCancel = onCancel
        }
        
        func cancel() {
            onCancel()
        }
    }
    
    func loadImageData(from url: URL, completion: @escaping (Completion)) -> FeedImageDataLoaderTask {
        messages.append((url, completion))
        return Task(onCancel: { [weak self] in
            self?.canceledURLs.append(url)
        })
    }
    
    func complete(with error: Error, at index: Int = 0) {
        messages[index].completion(.failure(error))
    }
    
    func complete(with data: Data, at index: Int = 0) {
        messages[index].completion(.success(data))
    }
}
