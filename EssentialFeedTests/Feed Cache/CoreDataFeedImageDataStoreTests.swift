//
//  CoreDataFeedImageDataStoreTests.swift
//  EssentialFeedTests
//
//  Created by Riccardo Rossi - Home on 10/06/21.
//

import XCTest
import EssentialFeed

extension CoreDataFeedStore: FeedImageDataStore {
    public func retrieve(dataFor url: URL, completion: @escaping (FeedImageDataStore.RetrievalResult) -> Void) {
        completion(.success(.none))
    }
    
    public func insert(_ data: Data, for url: URL, completion: @escaping (FeedImageDataStore.InsertionResult) -> Void) {}
}

class CoreDataFeedImageDataStoreTests: XCTestCase {

    func test_retrieve_deliversNotFoundWhenEmtpy() {
        let sut = makeSUT()
        
        expect(sut, toCompleteRetrievalWith: notFound())
    }
    
    func test_retrieve_deliversNotFoundWhenNotFoundURLInNonEmptyStore() {
        let sut = makeSUT()
        let insertedURL = URL(string: "http://a-url.com")!
        
        sut.insert(anyData(), for: insertedURL, completion: { _ in })
        
        let toBeRetrievedURL = URL(string: "http://a-different-url.com")!
        expect(sut, toCompleteRetrievalWith: notFound(), for: toBeRetrievedURL)
    }
    
    private func expect(_ sut: FeedImageDataStore, toCompleteRetrievalWith expectedResult: FeedImageDataStore.RetrievalResult, for url: URL = anyURL(), file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for retrieve completion")
        
        sut.retrieve(dataFor: url) { receivedResult in
            switch (expectedResult, receivedResult) {
            
            case (.success(let expectedData), .success(let receivedData)):
                XCTAssertEqual(expectedData, receivedData, file: file, line: line)
            
            default:
                XCTFail("Expected \(expectedResult), got \(receivedResult) instead")
            
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private func notFound() -> FeedImageDataStore.RetrievalResult {
        return .success(.none)
    }
    
    private func makeSUT() -> FeedImageDataStore {
        let storeBundle = Bundle(for: CoreDataFeedStore.self)
        let storeURL = URL(fileURLWithPath: "/dev/null")
        let sut = try! CoreDataFeedStore(storeURL: storeURL, bundle: storeBundle)
        trackForMemoryLeaks(sut)
        return sut
    }

}
