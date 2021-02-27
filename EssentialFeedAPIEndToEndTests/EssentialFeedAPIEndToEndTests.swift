//
//  EssentialFeedAPIEndToEndTests.swift
//  EssentialFeedAPIEndToEndTests
//
//  Created by Riccardo Rossi - Home on 22/02/21.
//

import XCTest
import EssentialFeed

class EssentialFeedAPIEndToEndTests: XCTestCase {

    func test_endToEndTestServerGETFeedResult_matchesFixedTestAccountData() {
        switch getFeedResult() {
        case .success(let items):
            XCTAssertEqual(items.count, 8, "Expected 8 items in the test account feed")
            
            XCTAssertEqual(items[0], expectedItem(at: 0))
            XCTAssertEqual(items[1], expectedItem(at: 1))
            XCTAssertEqual(items[2], expectedItem(at: 2))
            XCTAssertEqual(items[3], expectedItem(at: 3))
            XCTAssertEqual(items[4], expectedItem(at: 4))
            XCTAssertEqual(items[5], expectedItem(at: 5))
            XCTAssertEqual(items[6], expectedItem(at: 6))
            XCTAssertEqual(items[7], expectedItem(at: 7))
            
        case .failure(let error):
            XCTFail("Expected successful feed results, got failure with error \(error) instead")
        case .none:
            XCTFail("Expected successful feed results, got no result instead")
        }
    }
    
    // MARK: - Helpers
    
    private func getFeedResult(file: StaticString = #file, line: UInt = #line) -> LoadFeedResult? {
        let url = URL(string: "https://my-json-server.typicode.com/RRReDz/EssentialFeed/response")!
        let client = URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
        let loader = RemoteFeedLoader(client: client, url: url)
        
        trackForMemoryLeaks(client, file: file, line: line)
        trackForMemoryLeaks(loader, file: file, line: line)
        
        let exp = expectation(description: "Wait for laod completion")
        
        var receivedResult: LoadFeedResult?
        loader.load { result in
            receivedResult = result
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 5.0)
        
        return receivedResult
    }
    
    private func expectedItem(at index: Int) -> FeedItem {
        return FeedItem(
            id: expectedId(at: index),
            description: expectedDescription(at: index),
            location: expectedLocation(at: index),
            imageURL: expectedURL(at: index)
        )
    }
    
    private func expectedId(at index: Int) -> UUID {
        return UUID(
            uuidString: [
                "711a1a32-7566-11eb-9439-0242ac130002",
                "7d9f7d06-7566-11eb-9439-0242ac130002",
                "f83f47e4-b71b-42be-8fd8-27991ba27c24",
                "f3121454-48e5-413c-ba30-088f6dabb61a",
                "e3051644-f3d4-4855-abdc-d2b27262f9bc",
                "20f608ff-81ff-4d11-a2f9-f08f70f45641",
                "b680a7b7-d549-4d53-952c-e40dd1a9baf8",
                "0db1892f-109b-4a2c-af4f-a9d3ab80a56d"
            ][index]
        )!
    }
    
    private func expectedDescription(at index: Int) -> String? {
        return [
            "Description 1",
            nil,
            "Description 3",
            nil,
            "Description 5",
            "Description 6",
            "Description 7",
            "Description 8"
        ][index]
    }
    
    private func expectedLocation(at index: Int) -> String? {
        return [
            "Location 1",
            "Location 2",
            nil,
            nil,
            "Location 5",
            "Location 6",
            "Location 7",
            "Location 8"
        ][index]
    }
    
    private func expectedURL(at index: Int) -> URL {
        return URL(
            string: [
                "https://url-1.com",
                "https://url-2.com",
                "https://url-3.com",
                "https://url-4.com",
                "https://url-5.com",
                "https://url-6.com",
                "https://url-7.com",
                "https://url-8.com"
            ][index]
        )!
    }

}
