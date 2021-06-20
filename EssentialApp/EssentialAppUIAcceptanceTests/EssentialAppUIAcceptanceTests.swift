//
//  EssentialAppUIAcceptanceTests.swift
//  EssentialAppUIAcceptanceTests
//
//  Created by Riccardo Rossi - Home on 20/06/21.
//

import XCTest

class EssentialAppUIAcceptanceTests: XCTestCase {

    func test_onLaunch_displaysRemoteFeedWhenCustomerHasConnectivity() {
        let app = XCUIApplication()
        
        app.launch()
        _ = app.waitForExistence(timeout: 10)
        
        let feedCells = app.cells.matching(identifier: "feed-image-cell")
        XCTAssertEqual(feedCells.count, 8)
        
        let firstImage = app.images.matching(identifier: "feed-image-view").firstMatch
        XCTAssert(firstImage.exists)
    }
}
