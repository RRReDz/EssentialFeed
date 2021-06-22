//
//  SceneDelegateTests.swift
//  EssentialAppTests
//
//  Created by Riccardo Rossi - Home on 22/06/21.
//

import XCTest
import EssentialFeediOS
@testable import EssentialApp

class SceneDelegateTests: XCTestCase {

    func test_sceneDelegateWillConnectToSession_configuresRootViewController() {
        let sut = SceneDelegate()
        sut.window = UIWindow()
        
        sut.configureWindow()
        
        let root = sut.window?.rootViewController
        let rootNavigation = root as? UINavigationController
        let topController = rootNavigation?.topViewController
        
        XCTAssertNotNil(rootNavigation, "Expected root to be a UINavigationController, got \(String(describing: root)) instead")
        XCTAssert(topController is FeedViewController, "Expected top controller to be a FeedViewController, got \(String(describing: topController)) instead")
    }

}
