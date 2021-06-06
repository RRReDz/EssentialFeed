//
//  LoadFeedImageFromRemoteUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Riccardo Rossi - Home on 05/06/21.
//

import XCTest
import EssentialFeed

final class RemoteFeedImageDataLoader {
    private let client: HTTPClient
    
    init(client: HTTPClient) {
        self.client = client
    }
    
    enum Error: Swift.Error {
        case invalidData
    }
    
    private struct WrappedDataLoaderTask: FeedImageDataLoaderTask {
        let wrappedTask: HTTPClientTask
        
        func cancel() {
            wrappedTask.cancel()
        }
    }
    
    @discardableResult
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Completion)) -> FeedImageDataLoaderTask {
        let task = client.get(from: url) { [weak self] result in
            guard self != nil else { return }
            
            switch result {
            case let .success((urlResponse, data)):
                if urlResponse.statusCode == 200, !data.isEmpty {
                    completion(.success(data))
                } else {
                    completion(.failure(Error.invalidData))
                }
            case let .failure(error):
                completion(.failure(error))
            }
        }
        return WrappedDataLoaderTask(wrappedTask: task)
    }
}

class LoadFeedImageFromRemoteUseCaseTests: XCTestCase {

    func test_init_doesNotPerformAnyURLRequest() {
        let (_, client) = makeSUT()
        
        XCTAssert(client.requestedURLs.isEmpty)
    }
    
    func test_loadImageDataFromURL_requestsDataFromURL() {
        let (sut, client) = makeSUT()
        let url = anyURL()
        
        sut.loadImageData(from: url) { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_loadImageDataFromURLTwice_requestsDataFromURLTwice() {
        let (sut, client) = makeSUT()
        let url = anyURL()
        
        sut.loadImageData(from: url) { _ in }
        sut.loadImageData(from: url) { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_loadImageDataFromURL_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        let clientError = anyNSError()
        
        expect(sut, toCompleteWith: .failure(clientError), when: {
            client.complete(with: clientError)
        })
    }
    
    func test_loadImageDataFromURL_deliversInvalidDataErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()
        let codes = [199, 201, 300, 400, 500]
        
        codes.enumerated().forEach { index, code in
            expect(sut, toCompleteWith: failure(.invalidData), when: {
                client.complete(withStatusCode: code, data: anyData(), at: index)
            })
        }
    }
    
    func test_loadImageDataFromURL_deliversInvalidDataErrorOn200HTTPResponseWithEmptyData() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWith: failure(.invalidData), when: {
            let emptyData = Data()
            client.complete(withStatusCode: 200, data: emptyData)
        })
    }
    
    func test_loadImageDataFromURL_deliversNonEmptyDataOn200HTTPResponseAndNonEmptyData() {
        let (sut, client) = makeSUT()
        let nonEmptyData = Data("non-empty data".utf8)
        
        expect(sut, toCompleteWith: .success(nonEmptyData), when: {
            client.complete(withStatusCode: 200, data: nonEmptyData)
        })
    }
    
    func test_loadImageDataFromURL_doesNotDeliverResultAfterInstanceHasBeenDeallocated() {
        let client = HTTPClientSpy()
        var sut: RemoteFeedImageDataLoader? = .init(client: client)
        
        var capturedResult: FeedImageDataLoader.Result?
        sut?.loadImageData(from: anyURL()) { capturedResult = $0 }
        sut = nil
        
        client.complete(withStatusCode: 200, data: anyData())
        
        XCTAssertNil(capturedResult)
    }
    
    func test_cancelLoadImageDataFromURL_cancelsClientURLRequest() {
        let (sut, client) = makeSUT()
        let url = anyURL()
        
        let task = sut.loadImageData(from: url, completion: { _ in })
        XCTAssertEqual(client.canceledURLs, [])
        
        task.cancel()
        XCTAssertEqual(client.canceledURLs, [url])
    }
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: RemoteFeedImageDataLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedImageDataLoader(client: client)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(client, file: file, line: line)
        return (sut, client)
    }
    
    private func expect(_ sut: RemoteFeedImageDataLoader, toCompleteWith expectedResult: FeedImageDataLoader.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        
        let url = anyURL()
        let exp = expectation(description: "Wait for load image data completion")
        
        sut.loadImageData(from: url) { receivedResult in
            
            switch (receivedResult, expectedResult) {
            case let (.success(receivedData), .success(expectedData)):
                XCTAssertEqual(receivedData, expectedData, file: file, line: line)
                
            case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
                
            default:
                XCTFail("Expected result \(expectedResult) got \(receivedResult) instead", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private func failure(_ error: RemoteFeedImageDataLoader.Error) -> FeedImageDataLoader.Result {
        return .failure(error)
    }
    
    private class HTTPClientSpy: HTTPClient {
        private struct Task: HTTPClientTask {
            private var onCancel: () -> Void
            
            init(onCancel: @escaping () -> Void) {
                self.onCancel = onCancel
            }
            
            func cancel() {
                onCancel()
            }
        }
        
        private var messages = [(url: URL, completion: (HTTPClient.Result) -> Void)]()
        
        var requestedURLs: [URL] {
            messages.map { $0.url }
        }
        
        var canceledURLs = [URL]()
        
        func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
            messages.append((url, completion))
            return Task(onCancel: { [weak self] in
                self?.canceledURLs.append(url)
            })
        }
        
        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
        
        func complete(withStatusCode code: Int, data: Data, at index: Int = 0) {
            let response = HTTPURLResponse(
                url: requestedURLs[index],
                statusCode: code,
                httpVersion: nil,
                headerFields: nil)!
            
            messages[index].completion(.success((response, data)))
        }
    }

}
