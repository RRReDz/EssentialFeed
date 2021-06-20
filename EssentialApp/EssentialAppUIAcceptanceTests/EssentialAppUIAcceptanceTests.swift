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
        
        app.launchAndWaitForExistence()
        
        let feedCells = app.cells.matching(identifier: "feed-image-cell")
        _ = feedCells.element.waitForExistence(timeout: 10)
        XCTAssertEqual(feedCells.count, 8)
        
        let firstImage = app.images.matching(identifier: "feed-image-view").firstMatch
        _ = firstImage.waitForExistence(timeout: 10)
        XCTAssert(firstImage.exists)
    }
    
    func test_onLaunch_displaysCachedRemoteFeedWhenCustomerHasNoConnectivity() {
        let onlineApp = XCUIApplication()
        onlineApp.launch()
        
        let onlineFeedCells = onlineApp.cells.matching(identifier: "feed-image-cell")
        let onlineImageView = onlineApp.images.matching(identifier: "feed-image-view").firstMatch
        _ = onlineFeedCells.element.waitForExistence(timeout: 10)
        _ = onlineImageView.waitForExistence(timeout: 10)
        
        let offlineApp = XCUIApplication()
        offlineApp.launchArguments = ["-connectivity", "offline"]
        offlineApp.launch()
        
        let offlineFeedCells = offlineApp.cells.matching(identifier: "feed-image-cell")
        let offlineImageView = offlineApp.images.matching(identifier: "feed-image-view").firstMatch
        _ = offlineFeedCells.element.waitForExistence(timeout: 10)
        _ = offlineImageView.waitForExistence(timeout: 10)
        
        let feedCells = offlineApp.cells.matching(identifier: "feed-image-cell")
        XCTAssertEqual(feedCells.count, 8)
        
        let firstImage = offlineApp.images.matching(identifier: "feed-image-view").firstMatch
        XCTAssert(firstImage.exists)
    }
}

private extension XCUIApplication {
    typealias LaunchArguments = [String]
    @discardableResult
    func launchAndWaitForExistence(with launchArguments: LaunchArguments = []) -> Bool {
        self.launchArguments = launchArguments
        launch()
        return waitForExistence(timeout: 10.0)
    }
}
