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
        expect(sut, toGet: .failure(.connectivity), onAction: {
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
            expect(sut, toGet: .failure(.invalidData), onAction: {
                // When
                client.complete(withStatusCode: statusCode, at: index)
            })
        }
    }
    
    func test_load_deliversErrorOn200HTTPResponseAndInvalidJson() {
        // Given
        let (sut, client) = makeSUT()
        
        // Then
        expect(sut, toGet: .failure(.invalidData), onAction: {
            // When
            let invalidJsonData: Data = "invalidJson".data(using: .utf8)!
            client.complete(withStatusCode: 200, and: invalidJsonData)
        })
    }
    
    func test_load_deliversNoItemsOn200HTTPResponseWithEmptyJSONList() {
        // Given
        let (sut, client) = makeSUT()
        
        // When
        expect(sut, toGet: .success([]), onAction: {
            // Then
            let emptyListJSONData: Data = "{\"items\":[]}".data(using: .utf8)!
            client.complete(withStatusCode: 200, and: emptyListJSONData)
        })
    }
    
    func test_load_deliversItemsOn200HTTPResponseWithValidJSONList() {
        // Given
        let (sut, client) = makeSUT()
        
        let feedItems: [FeedItem] = [
            FeedItem(
                id: UUID(),
                description: "My first feed item",
                location: "My first item location",
                imageURL: URL(string: "http://my-first-feed-url.com")!
            ),
            FeedItem(
                id: UUID(),
                description: nil,
                location: "My second item location",
                imageURL: URL(string: "http://my-second-feed-url.com")!
            ),
            FeedItem(
                id: UUID(),
                description: "My third item description",
                location: nil,
                imageURL: URL(string: "http://my-third-feed-url.com")!
            ),
            FeedItem(
                id: UUID(),
                description: nil,
                location: nil,
                imageURL: URL(string: "http://my-fourth-feed-url.com")!
            )
        ]
        
        let item1 = [
            "id": feedItems[0].id.description,
            "description": feedItems[0].description!,
            "location": feedItems[0].location!,
            "image": feedItems[0].imageURL.description
        ]
        let item2 = [
            "id": feedItems[1].id.description,
            "location": feedItems[1].location!,
            "image": feedItems[1].imageURL.description
        ]
        let item3 = [
            "id": feedItems[2].id.description,
            "description": feedItems[2].description!,
            "image": feedItems[2].imageURL.description
        ]
        let item4 = [
            "id": feedItems[3].id.description,
            "image": feedItems[3].imageURL.description
        ]
        
        let items = [
            "items": [item1, item2, item3, item4]
        ]
        
        // When
        expect(sut, toGet: .success(feedItems), onAction: {
            // Then
            let JSONData = try! JSONSerialization.data(withJSONObject: items)
            client.complete(withStatusCode: 200, and: JSONData)
        })
    }
    
    private func makeSUT(url: URL = URL(string: "http://another-fantastic-awesome-url.com")!) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(client: client, url: url)
        return (sut: sut, client: client)
    }
    
    private func expect(_ sut: RemoteFeedLoader, toGet result: RemoteFeedLoader.Result, onAction action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        var capturedResults: [RemoteFeedLoader.Result] = []
        sut.load { capturedResults.append($0) }
        action()
        XCTAssertEqual(capturedResults, [result], file: file, line: line)
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
