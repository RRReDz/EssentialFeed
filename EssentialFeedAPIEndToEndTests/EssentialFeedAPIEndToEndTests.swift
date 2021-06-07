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
        case .success(let imageFeed):
            XCTAssertEqual(imageFeed.count, 8, "Expected 8 images in the test account image feed")
            
            XCTAssertEqual(imageFeed[0], expectedImage(at: 0))
            XCTAssertEqual(imageFeed[1], expectedImage(at: 1))
            XCTAssertEqual(imageFeed[2], expectedImage(at: 2))
            XCTAssertEqual(imageFeed[3], expectedImage(at: 3))
            XCTAssertEqual(imageFeed[4], expectedImage(at: 4))
            XCTAssertEqual(imageFeed[5], expectedImage(at: 5))
            XCTAssertEqual(imageFeed[6], expectedImage(at: 6))
            XCTAssertEqual(imageFeed[7], expectedImage(at: 7))
            
        case .failure(let error):
            XCTFail("Expected successful feed results, got failure with error \(error) instead")
        case .none:
            XCTFail("Expected successful feed results, got no result instead")
        }
    }
    
    func test_endToEndTestServerGETFeedImageDataResult_matchesFixedTestAccountData() {
        switch getFeedImageDataResult() {
        case let .success(data)?:
            XCTAssertFalse(data.isEmpty, "Expected non-empty image data")
            
        case let .failure(error)?:
            XCTFail("Expected successful image data result, got \(error) instead")
            
        default:
            XCTFail("Expected successful image data result, got no result instead")
        }
    }
    
    // MARK: - Helpers
    
    private func getFeedResult(file: StaticString = #file, line: UInt = #line) -> FeedLoader.Result? {
        let url = URL(string: "https://my-json-server.typicode.com/RRReDz/EssentialFeed/response")!
        let loader = RemoteFeedLoader(client: ephemeralClient(), url: url)
       
        trackForMemoryLeaks(loader, file: file, line: line)
        
        let exp = expectation(description: "Wait for laod completion")
        
        var receivedResult: FeedLoader.Result?
        loader.load { result in
            receivedResult = result
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 5.0)
        
        return receivedResult
    }
    
    private func getFeedImageDataResult(file: StaticString = #file, line: UInt = #line) -> FeedImageDataLoader.Result? {
        let testServerURL = URL(string: "https://essentialdeveloper.com/feed-case-study/test-api/feed/73A7F70C-75DA-4C2E-B5A3-EED40DC53AA6/image")!
        let loader = RemoteFeedImageDataLoader(client: ephemeralClient())
        
        trackForMemoryLeaks(loader, file: file, line: line)
        
        let exp = expectation(description: "Wait for load completion")
        
        var receivedResult: FeedImageDataLoader.Result?
        _ = loader.loadImageData(from: testServerURL) { result in
            receivedResult = result
            exp.fulfill()
        }
        wait(for: [exp], timeout: 5.0)
        
        return receivedResult
    }
    
    private func ephemeralClient(file: StaticString = #file, line: UInt = #line) -> HTTPClient {
        let client = URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
        trackForMemoryLeaks(client, file: file, line: line)
        return client
    }
    
    private func expectedImage(at index: Int) -> FeedImage {
        return FeedImage(
            id: expectedId(at: index),
            description: expectedDescription(at: index),
            location: expectedLocation(at: index),
            url: expectedURL(at: index)
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
