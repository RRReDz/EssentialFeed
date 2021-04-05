//
//  FeedViewControllerTests.swift
//  EssentialFeediOSTests
//
//  Created by Riccardo Rossi - Home on 05/04/21.
//

import XCTest

final class FeedViewController: UIViewController {
    private var loader: FeedViewControllerTests.LoaderSpy
    
    init(loader: FeedViewControllerTests.LoaderSpy) {
        self.loader = loader
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loader.load()
    }
}

class FeedViewControllerTests: XCTestCase {

    func test_init_doesNotLoadFeed() {
        let loader = LoaderSpy()
        _ = FeedViewController(loader: loader)
        
        XCTAssertEqual(loader.loadCallCount, 0)
    }
    
    func test_viewDidLoad_loadsFeed() {
        let loader = LoaderSpy()
        let sut = FeedViewController(loader: loader)
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(loader.loadCallCount, 1)
    }
    
    final class LoaderSpy {
        private(set) var loadCallCount: Int = 0
        
        func load() {
            loadCallCount += 1
        }
    }
}
