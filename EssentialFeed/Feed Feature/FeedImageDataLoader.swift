//
//  FeedImageDataLoader.swift
//  EssentialFeediOS
//
//  Created by Riccardo Rossi - Home on 12/04/21.
//

import Foundation

public protocol FeedImageDataLoaderTask {
    func cancel()
}

public protocol FeedImageDataLoader {
    typealias Result = (Swift.Result<Data, Error>) -> Void
    
    func loadImageData(from url: URL, completion: @escaping (Result)) -> FeedImageDataLoaderTask
}
