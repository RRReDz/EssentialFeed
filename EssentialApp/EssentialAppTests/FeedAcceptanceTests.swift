//
//  FeedAcceptanceTests.swift
//  EssentialAppTests
//
//  Created by Riccardo Rossi - Home on 22/06/21.
//

import XCTest
import EssentialFeed
import EssentialFeediOS
@testable import EssentialApp

class FeedAcceptanceTests: XCTestCase {

    func test_onLaunch_displaysRemoteFeedWhenCustomerHasConnectivity() {
        let feed = launch(httpClient: .online(response), store: .empty)
        
        XCTAssertEqual(feed.numberOfRenderedFeedImageViews(), 2)
        XCTAssertEqual(feed.renderedFeedImageData(at: 0), makeImageData())
        XCTAssertEqual(feed.renderedFeedImageData(at: 1), makeImageData())
    }
    
    func test_onLaunch_displaysCachedRemoteFeedWhenCustomerHasNoConnectivity() {
        let store: InMemoryFeedStore = .empty
        let onlineFeed = launch(httpClient: .online(response), store: store)
        
        onlineFeed.simulateFeedImageViewVisible(at: 0)
        onlineFeed.simulateFeedImageViewVisible(at: 1)
        
        let offlineFeed = launch(httpClient: .offline, store: store)
        
        XCTAssertEqual(offlineFeed.numberOfRenderedFeedImageViews(), 2)
        XCTAssertEqual(offlineFeed.renderedFeedImageData(at: 0), makeImageData())
        XCTAssertEqual(offlineFeed.renderedFeedImageData(at: 1), makeImageData())
    }
    
    func test_onLaunch_displaysNOFeedWhenCustomerHasNoConnectivityAndNoCache() {
        let feed = launch(httpClient: .offline, store: .empty)
        
        XCTAssertEqual(feed.numberOfRenderedFeedImageViews(), 0)
    }
    
    func test_onEnteringBackground_deletesExpiredFeedCache() {
        let store = InMemoryFeedStore.withExpiredFeedCache
        
        enterBackground(with: store)
        
        XCTAssertNil(store.cachedFeed, "Expected to delete expired cache")
    }
    
    func test_onEnteringBackground_doesNotdeleteNonExpiredFeedCache() {
        let store = InMemoryFeedStore.withNonExpiredFeedCache
        
        enterBackground(with: store)
        
        XCTAssertNotNil(store.cachedFeed, "Expected not to delete non expired cache")
    }
    
    private func launch(
        httpClient: HTTPClientStub = .offline,
        store: InMemoryFeedStore = .empty
    ) -> FeedViewController {
        let sut = SceneDelegate(httpClient: httpClient, store: store)
        sut.window = UIWindow()
        sut.configureWindow()
        
        let nav = sut.window?.rootViewController as! UINavigationController
        return nav.topViewController as! FeedViewController
    }
    
    private func enterBackground(with store: InMemoryFeedStore) {
        let sut = SceneDelegate(httpClient: HTTPClientStub.offline, store: store)
        
        sut.sceneWillResignActive(UIApplication.shared.connectedScenes.first!)
    }
    
    private class HTTPClientStub: HTTPClient {
        private let stub: (URL) -> (HTTPClient.Result)
        
        init(stub: @escaping (URL) -> HTTPClient.Result) {
            self.stub = stub
        }
        
        private class Task: HTTPClientTask {
            func cancel() {}
        }
        
        func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
            completion(stub(url))
            return Task()
        }
        
        static var offline: HTTPClientStub {
            return HTTPClientStub(stub: { _ in .failure(anyNSError())})
        }
        
        static func online(_ stub: @escaping (URL) -> (HTTPURLResponse, Data)) -> HTTPClientStub {
            return HTTPClientStub(stub: { url in .success(stub(url))})
        }
    }
    
    private class InMemoryFeedStore: FeedStore, FeedImageDataStore {
        typealias CachedFeed = (feed: [LocalFeedImage], timestamp: Date)
        
        private init(cachedFeed: CachedFeed? = nil) {
            self.cachedFeed = cachedFeed
        }
        
        private(set) var cachedFeed: CachedFeed?
        private var cachedFeedImageData = [URL : Data]()
        
        func deleteCachedFeed(completion: @escaping DeletionCompletion) {
            cachedFeed = nil
            completion(.success(()))
        }
        
        func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
            cachedFeed = CachedFeed(feed: feed, timestamp: timestamp)
            completion(.success(()))
        }
        
        func retrieve(completion: @escaping RetrievalCompletion) {
            completion(.success(cachedFeed.map { ($0.feed, $0.timestamp) }))
        }
        
        func retrieve(dataFor url: URL, completion: @escaping (FeedImageDataStore.RetrievalResult) -> Void) {
            completion(.success(cachedFeedImageData[url]))
        }
        
        func insert(_ data: Data, for url: URL, completion: @escaping (InsertionResult) -> Void) {
            cachedFeedImageData[url] = data
        }
        
        static var empty: InMemoryFeedStore {
            return InMemoryFeedStore()
        }
        
        static var withExpiredFeedCache: InMemoryFeedStore {
            return InMemoryFeedStore(cachedFeed: (feed: [], timestamp: Date.distantPast))
        }
        
        static var withNonExpiredFeedCache: InMemoryFeedStore {
            return InMemoryFeedStore(cachedFeed: (feed: [], timestamp: Date()))
        }
    }
    
    private func response(for url: URL) -> (HTTPURLResponse, Data) {
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
        let data = makeData(for: url)
        return (response, data)
    }
    
    private func makeData(for url: URL) -> Data {
        switch url.absoluteString {
        case "http://image.com":
            return makeImageData()
        default:
            return makeFeedData()
        }
    }
    
    private func makeImageData() -> Data {
        return UIImage.make(withColor: .red).pngData()!
    }
    
    private func makeFeedData() -> Data {
        return try! JSONSerialization.data(
            withJSONObject: ["items": [
                ["id": UUID().uuidString, "image": "http://image.com"],
                ["id": UUID().uuidString, "image": "http://image.com"]
            ]])
    }

}

