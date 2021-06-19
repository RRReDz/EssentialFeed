//
//  SharedTestHelpers.swift
//  EssentialAppTests
//
//  Created by Riccardo Rossi - Home on 19/06/21.
//

import Foundation

func anyURL() -> URL {
    return URL(string: "http://any-url.com")!
}

func anyNSError() -> NSError {
    return NSError(domain: "any domain", code: 1)
}

func anyData() -> Data {
    return Data("any data".utf8)
}
