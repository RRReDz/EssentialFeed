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
        
        let validJSON = try! makeItemJSON([
            makeItem(
                id: UUID(),
                description: "A description",
                location: "A location",
                imageURL: URL(string: "http://a-url.com")!
            ).json]
        )
        
        statusCodes.enumerated().forEach { index, statusCode in
            // Then
            expect(sut, toGet: .failure(.invalidData), onAction: {
                // When
                client.complete(withStatusCode: statusCode, and: validJSON, at: index)
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
        
        let item1 = makeItem(
            id: UUID(),
            description: "My first feed item",
            location: "My first item location",
            imageURL: URL(string: "http://my-first-feed-url.com")!)
        
        let item2 = makeItem(
            id: UUID(),
            description: nil,
            location: "My second item location",
            imageURL: URL(string: "http://my-second-feed-url.com")!)
        
        let item3 = makeItem(
            id: UUID(),
            description: nil,
            location: "My second item location",
            imageURL: URL(string: "http://my-third-feed-url.com")!)
        
        let item4 = makeItem(
            id: UUID(),
            description: nil,
            location: nil,
            imageURL: URL(string: "http://my-second-feed-url.com")!)
        
        let allItems = [item1, item2, item3, item4]
        
        // When
        expect(sut, toGet: .success(allItems.map{$0.model}), onAction: {
            // Then
            let JSONData = try! makeItemJSON(allItems.map{$0.json})
            client.complete(withStatusCode: 200, and: JSONData)
        })
    }
    
    func test_load_deliversEmptyListWhenReferenceToSUTHasBeenLost() {
        // Given
        let url = URL(string: "http://a-random-url.com")!
        let client = HTTPClientSpy()
        var sut: RemoteFeedLoader? = RemoteFeedLoader(client: client, url: url)
        var capturedResults: [RemoteFeedLoader.Result] = []
        
        //When
        sut?.load(completion: {capturedResults.append($0)})
        sut = nil
        client.complete(withStatusCode: 200, and: try! makeItemJSON([]))
        
        // Then
        XCTAssertEqual(capturedResults, [])
    }
    
    private func makeSUT(url: URL = URL(string: "http://another-fantastic-awesome-url.com")!, file: StaticString = #file, line: UInt = #line) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(client: client, url: url)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(client, file: file, line: line)
        return (sut: sut, client: client)
    }
    
    private func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #file, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should have been deallocated. Potential memory leak.", file: file, line: line)
        }
    }
    
    private func expect(_ sut: RemoteFeedLoader, toGet result: RemoteFeedLoader.Result, onAction action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        var capturedResults: [RemoteFeedLoader.Result] = []
        sut.load { capturedResults.append($0) }
        action()
        XCTAssertEqual(capturedResults, [result], file: file, line: line)
    }
    
    private func makeItem(id: UUID, description: String?, location: String?, imageURL: URL) -> (model: FeedItem, json: [String: Any]) {
        let model = FeedItem(
            id: id,
            description: description,
            location: location,
            imageURL: imageURL
        )
        let json = [
            "id": id.description,
            "description": description,
            "location": location,
            "image": imageURL.description
        ].compactMapValues {$0}
        
        return (model, json)
    }
    
    private func makeItemJSON(_ items: [[String: Any]]) throws -> Data {
        let dictionaryItems = ["items": items]
        return try JSONSerialization.data(withJSONObject: dictionaryItems)
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
        
        func complete(withStatusCode statusCode: Int, and data: Data, at index: Int = 0) {
            let httpResponse = HTTPURLResponse(
                url: requestedURLs[index],
                statusCode: statusCode,
                httpVersion: nil,
                headerFields: nil)!
            messages[index].completion(.success(httpResponse, data))
        }
    }
}

private extension Dictionary {
    func serialize() throws -> Data {
        return try JSONSerialization.data(withJSONObject: self)
    }
}
