//
//  URLSessionHTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by Riccardo Rossi - Home on 17/02/21.
//

import XCTest
import EssentialFeed

class URLSessionHTTPClient {
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func get(from url: URL, completion: @escaping (HTTPClientResponse) -> Void) {
        session.dataTask(with: url, completionHandler: { _, _, error in
            if let error = error {
                completion(.failure(error))
            }
        }).resume()
    }
}

class URLSessionHTTPClientTests: XCTestCase {
    
        func test_getFromURL_performsGETRequestWithURL() {
            URLProtocolStub.startInterceptingRequests()
    
            let url = URL(string: "http://my-test-url.com")!
            let exp = XCTestExpectation(description: "Wait for request")
            
            URLProtocolStub.observeRequests { request in
                XCTAssertEqual(request.httpMethod, "GET")
                XCTAssertEqual(request.url, url)
                exp.fulfill()
            }
            
            URLSessionHTTPClient().get(from: url, completion: { _ in })
            
            wait(for: [exp], timeout: 2.0)
            
    
            URLProtocolStub.stopInterceptingRequests()
        }
    
    func test_getFromURL_failsOnRequestError() {
        URLProtocolStub.startInterceptingRequests()
        let url = URL(string: "http://any-url.com")!
        let error = NSError(domain: "Foo Error", code: 1)
        URLProtocolStub.stub(data: nil, response: nil, error: error)
        
        let sut = URLSessionHTTPClient()
        let exp = XCTestExpectation(description: "Expected to get response from get method")
        
        sut.get(from: url) { result in
            switch result {
            case .failure(let capturedError as NSError):
                XCTAssertEqual(capturedError.domain, error.domain)
                XCTAssertEqual(capturedError.code, error.code)
            default:
                XCTFail("Expected failure with error \(error) but we got \(result) instead")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 2.0)
        URLProtocolStub.stopInterceptingRequests()
    }
    
    // MARK - Helpers
    
    private class URLProtocolStub: URLProtocol {
        private static var stub: Stub?
        private static var requestObserver: ((URLRequest) -> Void)?
        
        private struct Stub {
            let data: Data?
            let response: URLResponse?
            let error: Error?
        }
        
        static func stub(data: Data?, response: URLResponse?, error: Error?) {
            stub = Stub(data: data, response: response, error: error)
        }
        
        static func observeRequests(completion: @escaping (URLRequest) -> Void) {
            URLProtocolStub.requestObserver = completion
        }
        
        static func startInterceptingRequests() {
            URLProtocol.registerClass(URLProtocolStub.self)
        }
        
        static func stopInterceptingRequests() {
            URLProtocol.unregisterClass(URLProtocolStub.self)
            stub = nil
            requestObserver = nil
        }
        
        override class func canInit(with request: URLRequest) -> Bool {
            URLProtocolStub.requestObserver?(request)
            return true
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }
        
        override func startLoading() {
            if let data = URLProtocolStub.stub?.data {
                client?.urlProtocol(self, didLoad: data)
            }
            
            if let response = URLProtocolStub.stub?.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            
            if let error = URLProtocolStub.stub?.error {
                client?.urlProtocol(self, didFailWithError: error)
            }
            
            client?.urlProtocolDidFinishLoading(self)
        }
        
        override func stopLoading() {}
    }
}
