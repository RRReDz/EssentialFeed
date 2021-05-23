//
//  CoreDataFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Riccardo Rossi - Home on 22/05/21.
//

import XCTest
import EssentialFeed

class CoreDataFeedStoreTests: XCTestCase, FeedStoreSpecs {
    func test_retrieve_deliversEmptyOnEmptyCache() {
        let sut = makeSUT()
        
        assertThatRetrieveDeliversEmptyOnEmptyCache(on: sut)
    }
    
    func test_retrieve_hasNoSideEffectsOnEmtpyCache() {
        let sut = makeSUT()
        
        assertThatRetrieveHasNoSideEffectsOnEmptyCache(on: sut)
    }
    
    func test_retrieve_deliversFoundValuesOnNonEmptyCache() {}
    
    func test_retrieve_hasNoSideEffectsOnNonEmptyCache() {}
    
    func test_insert_deliversNoErrorOnEmptyCache() {}
    
    func test_insert_deliversNoErrorOnNonEmptyCache() {}
    
    func test_insert_overridesPreviouslyInsertedCacheValues() {}
    
    func test_delete_hasNoSideEffectsOnEmptyCache() {}
    
    func test_delete_doesNotDeliverErrorDeletingEmptyCache() {}
    
    func test_delete_leavesCacheEmptyOnNonEmptyCache() {}
    
    func test_delete_doesNotDeliverErrorOnNonEmptyCache() {}
    
    func test_storeSideEffects_runSerially() {}

    private func makeSUT() -> FeedStore {
        let sut = CoreDataFeedStore()
        trackForMemoryLeaks(sut)
        return sut
    }
}
