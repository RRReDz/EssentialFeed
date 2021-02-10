//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Riccardo Rossi on 10/02/21.
//

import XCTest

class RemoteFeedLoader {
    private let client: HTTPClient
    
    init(client: HTTPClient) {
        self.client = client
    }
    
    func load() {
        client.get(from: URL(string: "http://a-random-url.com")!)
    }
}

class HTTPClient {    
    func get(from url: URL) {}
}

class HTTPClientSpy: HTTPClient {
    override func get(from url: URL) {
        self.requestedURL = url
    }
    
    var requestedURL: URL?
    
    override init() {}
}

class RemoteFeedLoaderTests: XCTestCase {

    func test_notLoadingAnyURL_clientDoesNotRequestAnyURL() {
        // Given
        let client = HTTPClientSpy()
        _ = RemoteFeedLoader(client: client)
        
        // When (missing in this case)
        
        // Then
        XCTAssertNil(client.requestedURL)
    }
    
    func test_loadingAURL_clientDoesRequestAURL() {
        // Given
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(client: client)
        
        // When
        sut.load()
        
        // Then
        XCTAssertNotNil(client.requestedURL)
    }

}
