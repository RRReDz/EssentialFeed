//
//  HTTPClient.swift
//  EssentialFeed
//
//  Created by Riccardo Rossi on 15/02/21.
//

import Foundation

public enum HTTPClientResponse {
    case success(HTTPURLResponse, Data)
    case failure(Error)
}

public protocol HTTPClient {
    /// The completion handler can be invoked in any thread.
    /// Clients are responsible to dispatch to appropriate thread, if needed.
    func get(from url: URL, completion: @escaping (HTTPClientResponse) -> Void)
}
