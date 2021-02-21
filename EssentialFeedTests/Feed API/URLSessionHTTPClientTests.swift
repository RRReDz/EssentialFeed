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
    
    private struct UnexpectedValuesRapresentation: Error {}
    
    func get(from url: URL, completion: @escaping (HTTPClientResponse) -> Void) {
        session.dataTask(with: url, completionHandler: { data, response, error in
            if let error = error {
                completion(.failure(error))
            } else if let data = data, let response = response as? HTTPURLResponse {
                completion(.success(response, data))
            } else {
                completion(.failure(UnexpectedValuesRapresentation()))
            }
        }).resume()
    }
}

class URLSessionHTTPClientTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        URLProtocolStub.startInterceptingRequests()
    }
    
    override func tearDown() {
        super.tearDown()
        URLProtocolStub.stopInterceptingRequests()
    }
    
    func test_getFromURL_performsGETRequestWithURL() {
        let exp = XCTestExpectation(description: "Wait for request")
        let url = anyURL()
        
        URLProtocolStub.observeRequests { request in
            XCTAssertEqual(request.httpMethod, "GET")
            XCTAssertEqual(request.url, url)
            exp.fulfill()
        }
        
        makeSUT().get(from: url, completion: { _ in })
        
        wait(for: [exp], timeout: 2.0)
    }
    
    func test_getFromURL_failsOnRequestError() {
        let requestError = anyNSError()
        
        let receivedError = resultErrorFor(data: nil, response: nil, error: requestError) as NSError?
        
        XCTAssertEqual(receivedError?.domain, requestError.domain)
        XCTAssertEqual(receivedError?.code, requestError.code)
    }
    
    func test_getFromURL_failsOnRequestAllInvalidRepresentationCases() {
        XCTAssertNotNil(resultErrorFor(data: nil, response: nil, error: nil))
        XCTAssertNotNil(resultErrorFor(data: nil, response: anyURLResponse(), error: nil))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nil, error: nil))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nil, error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: nil, response: anyURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: nil, response: anyHTTPURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: anyURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: anyHTTPURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: anyURLResponse(), error: nil))
    }
    
    func test_getFromURL_succeedOnAnyURLHTTPResponseWithData() {
        let data = anyData()
        let response = anyHTTPURLResponse()
        let exp = XCTestExpectation(description: "Wait for response")
        
        URLProtocolStub.stub(data: data, response: response, error: nil)

        makeSUT().get(from: anyURL(), completion: { result in
            switch result {
            case .success(let retrievedResponse, let retrievedData):
                XCTAssertEqual(retrievedResponse.statusCode, response.statusCode)
                XCTAssertEqual(retrievedResponse.url, response.url)
                XCTAssertEqual(retrievedData, data)
            case .failure(let error):
                XCTFail("Expected success response \(response) with data \(data), got \(error) instead")
            }
            exp.fulfill()
        })
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_getFromURL_succeedWithEmptyDataOnAnyURLHTTPResponseWithoutData() {
        let response = anyHTTPURLResponse()
        let exp = XCTestExpectation(description: "Wait for response")
        let emptyData = Data()
        
        URLProtocolStub.stub(data: nil, response: response, error: nil)

        makeSUT().get(from: anyURL(), completion: { result in
            switch result {
            case .success(let retrievedResponse, let retrievedData):
                XCTAssertEqual(retrievedResponse.statusCode, response.statusCode)
                XCTAssertEqual(retrievedResponse.url, response.url)
                XCTAssertEqual(retrievedData, emptyData)
            case .failure(let error):
                XCTFail("Expected success response \(response) with data \(emptyData), got \(error) instead")
            }
            exp.fulfill()
        })
        
        wait(for: [exp], timeout: 1.0)
    }
    
    // MARK - Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> URLSessionHTTPClient {
        let sut = URLSessionHTTPClient()
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private func resultErrorFor(data: Data?, response: URLResponse?, error: Error?, file: StaticString = #file, line: UInt = #line) -> Error? {
        URLProtocolStub.stub(data: data, response: response, error: error)
        let sut = makeSUT(file: file, line: line)
        let exp = XCTestExpectation(description: "Expected to get response from get method")
        var capturedError: Error?
        
        sut.get(from: anyURL()) { result in
            switch result {
            case .failure(let error):
                capturedError = error
            default:
                XCTFail("Expected failure but we got \(result) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        return capturedError
    }
    
    private func anyURL() -> URL {
        return URL(string: "http://any-url.com")!
    }
    
    private func anyURLResponse() -> URLResponse {
        return URLResponse(
            url: anyURL(),
            mimeType: nil,
            expectedContentLength: 1,
            textEncodingName: nil
        )
    }
    
    private func anyHTTPURLResponse() -> HTTPURLResponse {
        return HTTPURLResponse(
            url: anyURL(),
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )!
    }
    
    private func anyData() -> Data {
        return "any data".data(using: .utf8)!
    }
    
    private func anyNSError() -> NSError {
        return NSError(domain: "Foo Error", code: 1)
    }
    
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
