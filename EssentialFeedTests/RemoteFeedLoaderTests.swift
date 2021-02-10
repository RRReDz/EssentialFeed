//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Riccardo Rossi on 10/02/21.
//

import XCTest

class RemoteFeedLoader {
    private let client: HTTPClient
    private let url: URL
    
    init(client: HTTPClient, url: URL) {
        self.client = client
        self.url = url
    }
    
    func load() {
        client.get(from: url)
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

    func test_notLoadingAnyURL_doesNotRequestDataFromURL() {
        // Given
        let client = HTTPClientSpy()
        _ = RemoteFeedLoader(client: client, url: URL(string: "http://an-awesome-url.com")!)
        
        // When (missing in this case)
        
        // Then
        XCTAssertNil(client.requestedURL)
    }
    
    func test_loadingAURL_doesRequestDataFromURL() {
        // Given
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(client: client, url: URL(string: "http://another-awesome-url.com")!)
        
        // When
        sut.load()
        
        // Then
        XCTAssertNotNil(client.requestedURL)
    }
    
    func test_loadingAURL_doesRequestDataFromThatURL() {
        // Given
        let client = HTTPClientSpy()
        let url = URL(string: "http://another-fantastic-awesome-url.com")!
        let sut = RemoteFeedLoader(client: client, url: url)
        
        // When
        sut.load()
        
        // Then
        XCTAssertEqual(client.requestedURL, url)
    }

}
