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
        
        let (feedCells, firstImage) = app.waitForFeedCellsAndFirstImageExistence()
        
        XCTAssertEqual(feedCells.count, 8)
        XCTAssert(firstImage.exists)
    }
    
    func test_onLaunch_displaysCachedRemoteFeedWhenCustomerHasNoConnectivity() {
        let onlineApp = XCUIApplication()
        onlineApp.launchAndWaitForExistence()
        
        onlineApp.waitForFeedCellsAndFirstImageExistence()
        
        let offlineApp = XCUIApplication()
        offlineApp.launchAndWaitForExistence(with: ["-connectivity", "offline"])
        
        let (offlineFeedCells, offlineFirstImage) = offlineApp.waitForFeedCellsAndFirstImageExistence()
        
        XCTAssertEqual(offlineFeedCells.count, 8)
        XCTAssert(offlineFirstImage.exists)
    }
    
    func test_onLaunch_displaysNOFeedWhenCustomerHasNoConnectivityAndNoCache() {
        let offlineApp = XCUIApplication()
        offlineApp.launchAndWaitForExistence(with: ["-reset", "-connectivity", "offline"])
        
        let (offlineFeedCells, _) = offlineApp.waitForFeedCellsAndFirstImageExistence()
        
        XCTAssertEqual(offlineFeedCells.count, 0)
    }
}

private extension XCUIApplication {
    typealias LaunchArguments = [String]
    
    private static let defaultTimeout: Double = 5.0

    func launchAndWaitForExistence(with launchArguments: LaunchArguments = []) {
        self.launchArguments = launchArguments
        launch()
        _ = waitForExistence(timeout: Self.defaultTimeout)
    }
    
    @discardableResult
    func waitForFeedCellsAndFirstImageExistence() -> (feedCells: [XCUIElement], firstImage: XCUIElement) {
        let feedCells = feedImageCellsQuery
        let firstImage = imageViewQuery.firstMatch
        _ = feedCells.element.waitForExistence(timeout: Self.defaultTimeout)
        _ = firstImage.waitForExistence(timeout: Self.defaultTimeout)
        return (feedCells.allElementsBoundByIndex, firstImage)
    }
    
    var feedImageCellsQuery: XCUIElementQuery {
        return cells.matching(identifier: "feed-image-cell")
    }
    
    var imageViewQuery: XCUIElementQuery {
        return images.matching(identifier: "feed-image-view")
    }
}
