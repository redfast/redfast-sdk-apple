//
//  MovieDetailsViewModelTests.swift
//  RedflixTests
//
//  Created by Volodymyr Mykhailiuk on 20.05.2024.
//

import XCTest
@testable import Redflix
import RedFast

final class MovieDetailsViewModelTests: XCTestCase {
    var viewModel: MovieDetailsViewModel!
    var services: MockServiceLocator!
    var coordinator: MockTabCoordinator!
    
    var itemStub: MovieRowViewModel {
        .stub(
            item: .stub(
                movieName: "Foo",
                director: "Bar",
                duration: "111",
                rating: "6",
                categoryId: "635c3e79a327a52ac5d7a7fc",
                shortDescription: "shortDescription",
                landscape: .init(url: "321"),
                portrait: .init(url: "123"),
                local: false
            ),
            type: .movies
        )
    }
    
    override func setUp() {
        services = MockServiceLocator()
        services.mockImageLoader = MockImageLoader()
        services.mockPromotionService = MockPromotionService()
        services.mockSDKStatusManager = MockSDKStatusManager()
        coordinator = MockTabCoordinator()
        viewModel = MovieDetailsViewModel(services: services, coordinator: coordinator, rowViewModel: itemStub)
    }
    
    override func tearDown() {
        viewModel = nil
        services = nil
        super.tearDown()
    }
    
    func testSetupSuccess() async {
        // Given
        let expImageData = Data([0100])
        services.mockImageLoader.mockData = expImageData

        // When
        await viewModel.setup()
        
        // Then
        XCTAssertEqual(viewModel.movieName, "Foo")
        XCTAssertEqual(viewModel.ratingString, "6.0")
        XCTAssertEqual(viewModel.category, "Adventure")
        XCTAssertEqual(viewModel.movieStarRating, 3)
        XCTAssertEqual(viewModel.movieDescription, "shortDescription")
        XCTAssertEqual(viewModel.duration, "111")
        XCTAssertEqual(viewModel.director, "Bar")
        XCTAssertEqual(services.mockImageLoader.invocations[0], .loadImageData)
        XCTAssertEqual(viewModel.imageData, expImageData)
    }
    
    func testRegisterScreen() async {
        // Given
        let promotionViewMock = MockPromotionView()
        promotionViewMock.screenName = "Foo"
        services.mockSDKStatusManager.isSDKInitialised.send(true)
        let expectedPromoResult = PromotionResult(code: .accepted, value: ["foo": "bar"])
        services.mockPromotionService.setScreenNameResult = expectedPromoResult
        
        // When
        viewModel.registerScreen(promotionViewMock)
        
        // Then
        XCTAssertEqual(services.mockPromotionService.invocations, [.setScreenName("Foo")])
        XCTAssertEqual(coordinator.invocations, [
            .handlePromotion(expectedPromoResult)
        ])
    }
}
