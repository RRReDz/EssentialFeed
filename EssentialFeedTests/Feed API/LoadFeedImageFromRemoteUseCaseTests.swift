//
//  LoadFeedImageFromRemoteUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Riccardo Rossi - Home on 05/06/21.
//

import XCTest

final class RemoteFeedImageDataLoader {
    init(client: Any) {
        
    }
}

class LoadFeedImageFromRemoteUseCaseTests: XCTestCase {

    func test_init_doesNotPerformAnyURLRequest() {
        let client = ClientSpy()
        _ = RemoteFeedImageDataLoader(client: client)
        
        XCTAssert(client.requestedURLs.isEmpty)
    }
    
    private class ClientSpy {
        var requestedURLs = [URL]()
    }

}
