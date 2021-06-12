//
//  CoreDataFeedImageDataStoreTests.swift
//  EssentialFeedTests
//
//  Created by Riccardo Rossi - Home on 10/06/21.
//

import XCTest
import EssentialFeed

class CoreDataFeedImageDataStoreTests: XCTestCase {

    func test_retrieve_deliversNotFoundWhenEmtpy() {
        let sut = makeSUT()
        
        expect(sut, toCompleteRetrievalWith: notFound())
    }
    
    func test_retrieve_deliversNotFoundWhenNotFoundURLInNonEmptyStore() {
        let sut = makeSUT()
        let url = URL(string: "http://a-url.com")!
        
        insert(anyData(), for: url, into: sut)
        
        let notFoundURL = URL(string: "http://not-found-url.com")!
        expect(sut, toCompleteRetrievalWith: notFound(), for: notFoundURL)
    }
    
    func test_retrieve_deliversDataWhenFoundMatchingURLInStore() {
        let sut = makeSUT()
        let matchingURL = anyURL()
        let data = anyData()
        
        insert(data, for: matchingURL, into: sut)
        
        expect(sut, toCompleteRetrievalWith: found(data), for: matchingURL)
    }
    
    func test_retrieve_overridesPreviousInsertedValuesForTheSameURL() {
        let sut = makeSUT()
        let url = anyURL()
        let firstStoredData = Data("first".utf8)
        let lastStoredData = Data("last".utf8)
        
        insert(firstStoredData, for: url, into: sut)
        insert(lastStoredData, for: url, into: sut)
        
        expect(sut, toCompleteRetrievalWith: found(lastStoredData), for: url)
    }
    
    func test_sideEffects_runsSerially() {
        let sut = makeSUT()
        let exp1 = expectation(description: "Wait for first insertion completion")
        let exp2 = expectation(description: "Wait for second insertion completion")
        let exp3 = expectation(description: "Wait for third insertion completion")
        
        sut.insert(anyData(), for: anyURL()) { _ in exp1.fulfill() }
        sut.insert(anyData(), for: anyURL()) { _ in exp2.fulfill() }
        sut.insert(anyData(), for: anyURL()) { _ in exp3.fulfill() }
        
        wait(for: [exp1, exp2, exp3], timeout: 1.0, enforceOrder: true)
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
    
    private func localImage(url: URL) -> LocalFeedImage {
        return LocalFeedImage(id: UUID(), description: "any", location: "any", url: url)
    }
    
    private func insert(_ data: Data, for url: URL, into sut: CoreDataFeedStore, file: StaticString = #file, line: UInt = #line) {
        let image = localImage(url: url)
        let exp = expectation(description: "Wait for image data insertion")
        
        sut.insert([image], timestamp: Date()) { cacheInsertResult in
            switch cacheInsertResult {
            
            case let .failure(error):
                XCTFail("Failed to insert image \(image) with error \(error)", file: file, line: line)
                exp.fulfill()
                
            case .success:
                sut.insert(data, for: url) { imageDataInsertResult in
                    if case let .failure(error) = imageDataInsertResult {
                        XCTFail("Failed to insert image data \(data) with error \(error)", file: file, line: line)
                    }
                    exp.fulfill()
                }
            }
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private func notFound() -> FeedImageDataStore.RetrievalResult {
        return .success(.none)
    }
    
    private func found(_ data: Data) -> FeedImageDataStore.RetrievalResult {
        return .success(data)
    }
    
    private func makeSUT() -> CoreDataFeedStore {
        let storeBundle = Bundle(for: CoreDataFeedStore.self)
        let storeURL = URL(fileURLWithPath: "/dev/null")
        let sut = try! CoreDataFeedStore(storeURL: storeURL, bundle: storeBundle)
        trackForMemoryLeaks(sut)
        return sut
    }

}
