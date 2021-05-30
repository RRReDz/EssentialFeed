//
//  FeedImagePresenterTests.swift
//  EssentialFeedTests
//
//  Created by Riccardo Rossi - Home on 30/05/21.
//

import XCTest
import EssentialFeed

struct FeedImageViewModel<Image> {
    let location: String?
    let description: String?
    let image: Image?
    let isLoading: Bool
    let retryLoading: Bool
}

protocol FeedImageView {
    associatedtype Image
    func display(_ viewModel: FeedImageViewModel<Image>)
}

final class FeedImagePresenter<ImageView: FeedImageView> {
    private let imageView: ImageView
    
    init(imageView: ImageView) {
        self.imageView = imageView
    }
    
    func startLoadingImageData(for model: FeedImage) {
        imageView.display(
            FeedImageViewModel(
                location: model.location,
                description: model.description,
                image: nil,
                isLoading: true,
                retryLoading: false))
    }
}

class FeedImagePresenterTests: XCTestCase {
    
    func test_init_doesNotSendMessageToView() {
        let (_, view) = makeSUT()
        
        XCTAssert(view.displayRepresentations.isEmpty)
    }
    
    func test_startLoadingImageData_askViewToDisplayFeedImageRepresentation() {
        let (sut, view) = makeSUT()
        let imageModel = uniqueImage()
        
        sut.startLoadingImageData(for: imageModel)
        
        let feedImage = makeFeedImageRepresentation(
            from: imageModel,
            image: nil,
            isLoading: true,
            retryLoading: false)
        XCTAssertEqual(view.displayRepresentations, [feedImage])
    }
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (FeedImagePresenter<ViewSpy>, ViewSpy) {
        let view = ViewSpy()
        let sut = FeedImagePresenter(imageView: view)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(view, file: file, line: line)
        return (sut, view)
    }
    
    private func makeFeedImageRepresentation(
        from model: FeedImage,
        image: String?,
        isLoading: Bool,
        retryLoading: Bool
    ) -> FeedImageRepresentation {
        return FeedImageRepresentation(
            location: model.location,
            description: model.description,
            image: nil,
            isLoading: true,
            retryLoading: false)
    }
    
    private final class ViewSpy: FeedImageView {
        var displayRepresentations = [FeedImageRepresentation]()
        
        func display(_ viewModel: FeedImageViewModel<String>) {
            displayRepresentations.append(FeedImageRepresentation(from: viewModel))
        }
    }
}

private struct FeedImageRepresentation: Equatable {
    let location: String?
    let description: String?
    let image: String?
    let isLoading: Bool
    let retryLoading: Bool
}

extension FeedImageRepresentation {
    init(from viewModel: FeedImageViewModel<String>) {
        location = viewModel.location
        description = viewModel.description
        image = viewModel.image
        isLoading = viewModel.isLoading
        retryLoading = viewModel.retryLoading
    }
}
