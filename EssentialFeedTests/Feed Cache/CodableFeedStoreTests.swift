//
//  CodableFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Riccardo Rossi - Home on 14/03/21.
//

import XCTest
import EssentialFeed

class CodableFeedStoreTests: XCTestCase, FailableFeedStoreSpecs {
    
    override func tearDown() {
        super.tearDown()
        
        undoStoreSideEffects()
    }
    
    override func setUp() {
        super.setUp()
        
        setupEmptyStoreState()
    }

    func test_retrieve_deliversEmptyOnEmptyCache() {
        assertThatRetrieveDeliversEmptyOnEmptyCache(on: makeSUT())
    }
    
    func test_retrieve_hasNoSideEffectsOnEmtpyCache() {
        assertThatRetrieveHasNoSideEffectsOnEmptyCache(on: makeSUT())
    }
    
    func test_retrieve_deliversFoundValuesOnNonEmptyCache() {
        assertThatRetrieveDeliversFoundValuesOnNonEmptyCache(on: makeSUT())
    }
    
    func test_retrieve_hasNoSideEffectsOnNonEmptyCache() {
        assertThatRetrieveHasNoSideEffectsOnNonEmptyCache(on: makeSUT())
    }
    
    func test_retrieve_deliversFailureOnRetrievalError() {
        let storeURL = testSpecificStoreURL()
        let sut = makeSUT(storeURL: storeURL)
        
        try! "invalid data".write(to: storeURL, atomically: false, encoding: .utf8)
        
        assertThatRetrieveDeliversFailureOnRetrievalError(on: sut)
    }
    
    func test_retrieve_hasNoSideEffectsOnFailure() {
        let storeURL = testSpecificStoreURL()
        let sut = makeSUT(storeURL: storeURL)
        
        try! "invalid data".write(to: storeURL, atomically: false, encoding: .utf8)
        
        assertThatRetrieveHasNoSideEffectsOnFailure(on: sut)
    }
    
    func test_insert_deliversNoErrorOnEmptyCache() {
        assertThatInsertDeliversNoErrorOnEmptyCache(on: makeSUT())
    }
    
    func test_insert_deliversNoErrorOnNonEmptyCache() {
        assertThatInsertDeliversNoErrorOnNonEmptyCache(on: makeSUT())
    }
    
    func test_insert_overridesPreviouslyInsertedCacheValues() {
        assertThatInsertOverridesPreviouslyInsertedCacheValues(on: makeSUT())
    }
    
    func test_insert_deliversErrorOnInsertionError() {
        let invalidStoreURL = URL(string: "invalid://store-url")!
        let sut = makeSUT(storeURL: invalidStoreURL)
        
        assertThatInsertDeliversErrorOnInsertionError(on: sut)
    }
    
    func test_insert_hasNoSideEffectsOnInsertionError() {
        let invalidStoreURL = URL(string: "invalid://store-url")!
        let sut = makeSUT(storeURL: invalidStoreURL)
        
        assertThatInsertHasNoSideEffectsOnInsertionError(on: sut)
    }
    
    func test_delete_hasNoSideEffectsOnEmptyCache() {
        assertThatDeleteHasNoSideEffectsOnEmptyCache(on: makeSUT())
    }
    
    func test_delete_doesNotDeliverErrorDeletingEmptyCache() {
        assertThatDeleteDoesNotDeliverErrorOnEmptyCache(on: makeSUT())
    }
    
    func test_delete_leavesCacheEmptyOnNonEmptyCache() {
        assertThatDeleteLeavesCacheEmptyOnNonEmptyCache(on: makeSUT())
    }
    
    func test_delete_doesNotDeliverErrorOnNonEmptyCache() {
        assertThatDeleteDoesNotDeliverErrorOnNonEmptyCache(on: makeSUT())
    }
    
    func test_delete_deliversErrorOnDeletionError() {
        let noDeletePermissionURL = cachesDirectory()
        let sut = makeSUT(storeURL: noDeletePermissionURL)
        
        assertThatDeleteDeliversErrorOnDeletionError(on: sut)
    }
    
    func test_delete_hasNoSideEffectsOnDeletionError() {
        let noDeletePermissionURL = cachesDirectory()
        let sut = makeSUT(storeURL: noDeletePermissionURL)
        
        assertThatDeleteHasNoSideEffectsOnDeletionError(on: sut)
    }
    
    func test_storeSideEffects_runSerially() {
        assertThatStoreSideEffectsRunSerially(on: makeSUT())
    }
    
    //MARK: - Helpers
    private func makeSUT(storeURL: URL? = nil, file: StaticString = #file, line: UInt = #line) -> FeedStore {
        let sut = CodableFeedStore(storeURL: storeURL ?? testSpecificStoreURL())
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private func testSpecificStoreURL() -> URL {
        return cachesDirectory().appendingPathComponent("\(type(of: self)).store")
    }
    
    private func cachesDirectory() -> URL {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
    
    private func deleteStoreArtifacts() {
        try? FileManager.default.removeItem(at: testSpecificStoreURL())
    }
    
    private func setupEmptyStoreState() {
        deleteStoreArtifacts()
    }
    
    private func undoStoreSideEffects() {
        deleteStoreArtifacts()
    }

}
