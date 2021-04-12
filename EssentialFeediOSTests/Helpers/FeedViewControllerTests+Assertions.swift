//
//  FeedViewControllerTests+Assertions.swift
//  EssentialFeediOSTests
//
//  Created by Riccardo Rossi - Home on 12/04/21.
//

import Foundation
import XCTest
import EssentialFeed
import EssentialFeediOS

extension FeedViewControllerTests {
    func assertThat(_ sut: FeedViewController, hasViewConfiguredFor feedImage: FeedImage, at index: Int, file: StaticString = #file, line: UInt = #line) {
        let view = sut.feedImageView(at: index) as? FeedImageCell
        XCTAssertNotNil(view, file: file, line: line)
        XCTAssertEqual(view?.isShowingLocation, feedImage.location != nil, file: file, line: line)
        XCTAssertEqual(view?.descriptionText, feedImage.description, file: file, line: line)
        XCTAssertEqual(view?.locationText, feedImage.location, file: file, line: line)
    }

    func assertThat(_ sut: FeedViewController, isRendering images: [FeedImage], file: StaticString = #file, line: UInt = #line) {
        XCTAssertEqual(sut.numberOfRenderedFeedImageViews(), images.count, file: file, line: line)
        images.enumerated().forEach { index, image in
            assertThat(sut, hasViewConfiguredFor: image, at: index, file: file, line: line)
        }
    }
}
