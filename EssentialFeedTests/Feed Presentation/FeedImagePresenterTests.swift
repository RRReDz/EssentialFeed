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

final class FeedImagePresenter<Image, ImageView: FeedImageView> where Image == ImageView.Image {
    private let imageView: ImageView
    private let imageTransformer: (Data) -> Image?
    
    init(imageView: ImageView, imageTransformer: @escaping (Data) -> Image?) {
        self.imageView = imageView
        self.imageTransformer = imageTransformer
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
    
    private struct InvalidImageDataError: Error {}
    
    func endLoadingImageData(with imageData: Data, for model: FeedImage) {
        guard let image = imageTransformer(imageData) else {
            return endLoadingImageData(with: InvalidImageDataError(), for: model)
        }
        imageView.display(
            FeedImageViewModel(
                location: model.location,
                description: model.description,
                image: image,
                isLoading: false,
                retryLoading: false))
    }
    
    func endLoadingImageData(with error: Error, for model: FeedImage) {
        imageView.display(
            FeedImageViewModel(
                location: model.location,
                description: model.description,
                image: nil,
                isLoading: false,
                retryLoading: true))
    }
}

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
        let (sut, view) = makeSUT(imageTransformer: { _ in return nil })
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
    ) -> FeedImageViewModel<FakeImage> {
        return FeedImageViewModel(
            location: model.location,
            description: model.description,
            image: image,
            isLoading: isLoading,
            retryLoading: retryLoading)
    }
    
    private func anyFakeImage() -> FakeImage {
        return FakeImage(named: "successful converted data into image")
    }
    
    private final class ViewSpy: FeedImageView {
        var displayRepresentations = [FeedImageViewModel<FakeImage>]()
        
        func display(_ viewModel: FeedImageViewModel<FakeImage>) {
            displayRepresentations.append(viewModel)
        }
    }
    
    private struct FakeImage: Equatable {
        private let imageName: String
        
        init(named imageName: String) {
            self.imageName = imageName
        }
    }
}

extension FeedImageViewModel: Equatable where Image: Equatable {}
