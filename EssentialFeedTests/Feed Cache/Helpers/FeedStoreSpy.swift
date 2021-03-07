//
//  FeedStoreSpy.swift
//  EssentialFeedTests
//
//  Created by Riccardo Rossi - Home on 07/03/21.
//

import Foundation
import EssentialFeed

internal class FeedStoreSpy: FeedStore {
    internal enum ReceivedMessage: Equatable {
        case insert([LocalFeedImage], Date)
        case deleteCacheFeed
        case retrieve
    }
    
    private(set) var receivedMessages: [ReceivedMessage] = []
    
    internal var deletionCompletions: [DeletionCompletion] = []
    internal var insertionCompletions: [InsertionCompletion] = []
    
    // Called by LocalFeedLoader
    
    internal func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        deletionCompletions.append(completion)
        receivedMessages.append(.deleteCacheFeed)
    }
    
    internal func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        insertionCompletions.append(completion)
        receivedMessages.append(.insert(feed, timestamp))
    }
    
    internal func retrieve() {
        receivedMessages.append(.retrieve)
    }
    
    // Called by Tests
    
    internal func completeDeletion(with error: Error, at index: Int = 0) {
        deletionCompletions[index](error)
    }
    
    internal func completeInsertion(with error: Error, at index: Int = 0) {
        insertionCompletions[index](error)
    }
    
    internal func completeDeletionWithSuccess(at index: Int = 0) {
        deletionCompletions[index](nil)
    }
    
    internal func completeInsertionWithSuccess(at index: Int = 0) {
        insertionCompletions[index](nil)
    }
}
