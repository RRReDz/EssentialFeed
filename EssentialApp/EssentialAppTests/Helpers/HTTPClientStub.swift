//
//  HTTPClientStub.swift
//  EssentialAppTests
//
//  Created by Riccardo Rossi - Home on 26/06/21.
//

import Foundation
import EssentialFeed

class HTTPClientStub: HTTPClient {
    private let stub: (URL) -> (HTTPClient.Result)
    
    init(stub: @escaping (URL) -> HTTPClient.Result) {
        self.stub = stub
    }
    
    private class Task: HTTPClientTask {
        func cancel() {}
    }
    
    func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
        completion(stub(url))
        return Task()
    }
    
    static var offline: HTTPClientStub {
        return HTTPClientStub(stub: { _ in .failure(anyNSError())})
    }
    
    static func online(_ stub: @escaping (URL) -> (HTTPURLResponse, Data)) -> HTTPClientStub {
        return HTTPClientStub(stub: { url in .success(stub(url))})
    }
}
