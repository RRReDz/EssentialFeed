//
//  EssentialAppUIAcceptanceTests.swift
//  EssentialAppUIAcceptanceTests
//
//  Created by Riccardo Rossi - Home on 20/06/21.
//

import XCTest

class EssentialAppUIAcceptanceTests: XCTestCase {

    func test_onLaunch_displaysRemoteFeedWhenCustomerHasConnectivity() throws {
        let app = XCUIApplication()
        
        app.launchAndWaitForExistence()
        
        let (feedCells, firstImage) = try app.waitForFeedCellsAndFirstImageExistence()
        
        XCTAssertEqual(feedCells.count, 8)
        XCTAssert(firstImage.exists)
    }
    
    func test_onLaunch_displaysCachedRemoteFeedWhenCustomerHasNoConnectivity() throws {
        let onlineApp = XCUIApplication()
        onlineApp.launchAndWaitForExistence()
        
        try onlineApp.waitForFeedCellsAndFirstImageExistence()
        
        let offlineApp = XCUIApplication()
        offlineApp.launchAndWaitForExistence(with: ["-connectivity", "offline"])
        
        let (offlineFeedCells, offlineFirstImage) = try offlineApp.waitForFeedCellsAndFirstImageExistence()
        
        XCTAssertEqual(offlineFeedCells.count, 8)
        XCTAssert(offlineFirstImage.exists)
    }
}

private extension XCUIApplication {
    typealias LaunchArguments = [String]
    
    private static let defaultTimeout: Double = 10.0

    func launchAndWaitForExistence(with launchArguments: LaunchArguments = [], file: StaticString = #file, line: UInt = #line) {
        self.launchArguments = launchArguments
        launch()
        if !waitForExistence(timeout: Self.defaultTimeout) {
            XCTFail("Expected ui application to exist", file: file, line: line)
        }
    }
    
    @discardableResult
    func waitForFeedCellsAndFirstImageExistence(file: StaticString = #file, line: UInt = #line) throws -> (feedCells: [XCUIElement], firstImage: XCUIElement) {
        let feedCells = feedImageCellsQuery
        let firstImage = imageViewQuery.firstMatch
        let feedCellsExists = feedCells.element.waitForExistence(timeout: Self.defaultTimeout)
        let firstImageExist = firstImage.waitForExistence(timeout: Self.defaultTimeout)
        guard feedCellsExists && firstImageExist else {
            XCTFail("Expected both feed cells and first image to exist", file: file, line: line)
            throw NSError(domain: "wait for existence", code: 0)
        }
        return (feedCells.allElementsBoundByIndex, firstImage)
    }
    
    var feedImageCellsQuery: XCUIElementQuery {
        return cells.matching(identifier: "feed-image-cell")
    }
    
    var imageViewQuery: XCUIElementQuery {
        return images.matching(identifier: "feed-image-view")
    }
}
