//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Riccardo Rossi on 10/02/21.
//

import XCTest
import EssentialFeed

class RemoteFeedLoaderTests: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        // Given
        let (_, client) = makeSUT(url: URL(string: "http://an-awesome-url.com")!)
        
        // When (missing in this case)
        
        // Then
        XCTAssertEqual(client.requestedURLs, [])
    }
    
    func test_load_doesRequestDataFromThatURL() {
        // Given
        let url = URL(string: "http://another-fantastic-awesome-url.com")!
        let (sut, client) = makeSUT(url: url)
        
        // When
        sut.load()
        
        // Then
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_loadTwice_doesRequestDataFromThatURLTwice() {
        // Given
        let url = URL(string: "http://another-fantastic-awesome-url.com")!
        let (sut, client) = makeSUT(url: url)
        
        // When
        sut.load()
        sut.load()
        
        // Then
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_load_deliversErrorOnClientError() {
        // Given
        let (sut, client) = makeSUT()
        var capturedError: RemoteFeedLoader.Error?
        
        // When
        sut.load { error in
            capturedError = error
        }
        client.completions[0](NSError(domain: "MyError", code: 1, userInfo: nil))
        
        // Then
        XCTAssertEqual(capturedError, .connectivity)
    }
    
    private func makeSUT(url: URL = URL(string: "http://another-fantastic-awesome-url.com")!) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(client: client, url: url)
        return (sut: sut, client: client)
    }
    
    private class HTTPClientSpy: HTTPClient {
        init() {}
        
        var requestedURLs: [URL] = []
        var completions: [(Error) -> Void] = []
        
        func get(from url: URL, completion: @escaping (Error) -> Void) {
            self.requestedURLs.append(url)
            self.completions.append(completion)
        }
    }
}
