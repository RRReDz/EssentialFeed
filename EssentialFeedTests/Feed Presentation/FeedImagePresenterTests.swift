//
//  FeedImagePresenterTests.swift
//  EssentialFeedTests
//
//  Created by Riccardo Rossi - Home on 30/05/21.
//

import XCTest
import EssentialFeed

class FeedImagePresenterTests: XCTestCase {
    
    func test_init_doesNotSendMessageToView() {
        let (_, view) = makeSUT()
        
        XCTAssert(view.displayRepresentations.isEmpty)
    }
    
    func test_startLoadingImageData_displaysLoadingFeedImageRepresentation() {
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
    
    func test_endLoadingImageData_displaysFeedImageRepresentationOnSuccessfulImageTransformation() {
        let image = anyFakeImage()
        let (sut, view) = makeSUT(imageTransformer: { _ in return image })
        let imageModel = uniqueImage()
        
        sut.endLoadingImageData(with: anyData(), for: imageModel)
        
        let feedImage = makeFeedImageRepresentation(
            from: imageModel,
            image: image,
            isLoading: false,
            retryLoading: false)
        XCTAssertEqual(view.displayRepresentations, [feedImage])
    }
    
    func test_endLoadingImageData_displaysRetryFeedImageRepresentationOnFailingImageTransformation() {
        let (sut, view) = makeSUT(imageTransformer: fail)
        let imageModel = uniqueImage()
        
        sut.endLoadingImageData(with: anyData(), for: imageModel)
        
        let feedImage = makeFeedImageRepresentation(
            from: imageModel,
            image: nil,
            isLoading: false,
            retryLoading: true)
        XCTAssertEqual(view.displayRepresentations, [feedImage])
    }
    
    func test_endLoadingImageDataWithError_displaysRetryFeedImageRepresentation() {
        let (sut, view) = makeSUT()
        let imageModel = uniqueImage()
        let error = anyNSError()
        
        sut.endLoadingImageData(with: error, for: imageModel)
        
        let feedImage = makeFeedImageRepresentation(
            from: imageModel,
            image: nil,
            isLoading: false,
            retryLoading: true)
        XCTAssertEqual(view.displayRepresentations, [feedImage])
    }
    
    // MARK: - Helpers
    
    private func makeSUT(
        imageTransformer: ((Data) -> FakeImage?)? = nil,
        file: StaticString = #file,
        line: UInt = #line) -> (FeedImagePresenter<FakeImage, ViewSpy>, ViewSpy) {
        let view = ViewSpy()
        let sut = FeedImagePresenter(
            imageView: view,
            imageTransformer: imageTransformer ?? { _ in return nil })
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(view, file: file, line: line)
        return (sut, view)
    }
    
    private func makeFeedImageRepresentation(
        from model: FeedImage,
        image: FakeImage?,
        isLoading: Bool,
        retryLoading: Bool
    ) -> FeedImageRepresentation {
        return FeedImageRepresentation(
            location: model.location,
            description: model.description,
            image: image,
            isLoading: isLoading,
            retryLoading: retryLoading)
    }
    
    private var fail: (Data) -> FakeImage? {
        return { _ in nil }
    }
    
    private func anyFakeImage() -> FakeImage {
        return FakeImage(named: "successful converted data into image")
    }
    
    private final class ViewSpy: FeedImageView {
        var displayRepresentations = [FeedImageRepresentation]()
        
        func display(_ viewModel: FeedImageViewModel<FakeImage>) {
            displayRepresentations.append(FeedImageRepresentation.make(from: viewModel))
        }
    }
    
    private struct FakeImage: Equatable {
        private let imageName: String
        
        init(named imageName: String) {
            self.imageName = imageName
        }
    }
    
    private struct FeedImageRepresentation: Equatable {
        let location: String?
        let description: String?
        let image: FakeImage?
        let isLoading: Bool
        let retryLoading: Bool
        
        static func make(from viewModel: FeedImageViewModel<FakeImage>) -> FeedImageRepresentation {
            return FeedImageRepresentation(
                location: viewModel.location,
                description: viewModel.description,
                image: viewModel.image,
                isLoading: viewModel.isLoading,
                retryLoading: viewModel.retryLoading)
        }
    }
}
