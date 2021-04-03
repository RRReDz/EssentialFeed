//
//  HTTPClient.swift
//  EssentialFeed
//
//  Created by Riccardo Rossi on 15/02/21.
//

import Foundation

public protocol HTTPClient {
    typealias Result = Swift.Result<(HTTPURLResponse, Data), Error>
    
    /// The completion handler can be invoked in any thread.
    /// Clients are responsible to dispatch to appropriate thread, if needed.
    func get(from url: URL, completion: @escaping (Result) -> Void)
}
