//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Riccardo Rossi on 10/02/21.
//

import XCTest

class RemoteFeedLoader {
    func load() {
        HTTPClient.shared.get(from: URL(string: "http://a-random-url.com")!)
    }
}

class HTTPClient {
    static var shared = HTTPClient()
    
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
        HTTPClient.shared = client
        _ = RemoteFeedLoader()
        
        // When (missing in this case)
        
        // Then
        XCTAssertNil(client.requestedURL)
    }
    
    func test_loadingAURL_clientDoesRequestAURL() {
        // Given
        let client = HTTPClientSpy()
        HTTPClient.shared = client
        let sut = RemoteFeedLoader()
        
        // When
        sut.load()
        
        // Then
        XCTAssertNotNil(client.requestedURL)
    }

}
