//
//  SharedTestHelpers.swift
//  EssentialFeedTests
//
//  Created by Riccardo Rossi - Home on 12/03/21.
//

import Foundation

func anyURL() -> URL {
    return URL(string: "http://any-url.com")!
}

func anyNSError() -> NSError {
    return NSError(domain: "Foo Error", code: 1)
}

func anyData() -> Data {
    return "any data".data(using: .utf8)!
}
