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
        sut.load { _ in }
        
        // Then
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_loadTwice_doesRequestDataFromThatURLTwice() {
        // Given
        let url = URL(string: "http://another-fantastic-awesome-url.com")!
        let (sut, client) = makeSUT(url: url)
        
        // When
        sut.load { _ in }
        sut.load { _ in }
        
        // Then
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_load_deliversErrorOnClientError() {
        // Given
        let (sut, client) = makeSUT()
        
        // Then
        expect(sut, toGet: .connectivity, onAction: {
            // When
            let error = NSError(domain: "MyError", code: 1, userInfo: nil)
            client.complete(with: error)
        })
    }
    
    func test_load_deliversErrorOnClientNon200HTTPResponse() {
        // Given
        let (sut, client) = makeSUT()
        let statusCodes = [199, 201, 300, 400, 500]
        
        statusCodes.enumerated().forEach { index, statusCode in
            // Then
            expect(sut, toGet: .invalidData, onAction: {
                // When
                client.complete(withStatusCode: statusCode, at: index)
            })
        }
    }
    
    func test_load_deliversErrorOn200HTTPResponseAndInvalidJson() {
        // Given
        let (sut, client) = makeSUT()
        
        // Then
        expect(sut, toGet: .invalidData, onAction: {
            // When
            let invalidJsonData: Data = "invalidJson".data(using: .utf8)!
            client.complete(withStatusCode: 200, and: invalidJsonData)
        })
    }
    
    private func makeSUT(url: URL = URL(string: "http://another-fantastic-awesome-url.com")!) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(client: client, url: url)
        return (sut: sut, client: client)
    }
    
    private func expect(_ sut: RemoteFeedLoader, toGet error: RemoteFeedLoader.Error, onAction action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        var capturedErrors: [RemoteFeedLoader.Error] = []
        sut.load { capturedErrors.append($0) }
        action()
        XCTAssertEqual(capturedErrors, [error], file: file, line: line)
    }
    
    private class HTTPClientSpy: HTTPClient {
        init() {}
        
        var requestedURLs: [URL] { self.messages.map{$0.url} }
        
        var messages: [(url: URL, completion: (HTTPClientResponse) -> Void)] = []
        
        func get(from url: URL, completion: @escaping (HTTPClientResponse) -> Void) {
            self.messages.append((url: url, completion: completion))
        }
        
        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
        
        func complete(withStatusCode statusCode: Int, and data: Data = Data(), at index: Int = 0) {
            let httpResponse = HTTPURLResponse(
                url: requestedURLs[index],
                statusCode: statusCode,
                httpVersion: nil,
                headerFields: nil)!
            messages[index].completion(.success(httpResponse, data))
        }
    }
}
