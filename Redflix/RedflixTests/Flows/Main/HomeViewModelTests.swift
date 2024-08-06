//
//  HomeViewModelTests.swift
//  RedflixTests
//
//  Created by Volodymyr Mykhailiuk on 13.05.2024.
//

import XCTest
import RedFast
@testable import Redflix

final class HomeViewModelTests: XCTestCase {
    var viewModel: HomeViewModel!
    var services: MockServiceLocator!
    var coordinator: MockTabCoordinator!
    
    override func setUp() {
        services = MockServiceLocator()
        services.mockImageLoader = MockImageLoader()
        services.mockAPI = MockRedflixAPI()
        services.mockDate = MockDateFormatter()
        services.mockPromotionService = MockPromotionService()
        services.mockSDKStatusManager = MockSDKStatusManager()
        coordinator = MockTabCoordinator()
        viewModel = HomeViewModel(services: services, coordinator: coordinator, collectionId: "testCollection")
    }
    
    override func tearDown() {
        viewModel = nil
        services = nil
        super.tearDown()
    }
    
    func testSetupSuccess() async {
        // Given
        let mockResponse = MovieCollectionResponse(items: [
            .stub(movieName: "Silent Hill"),
            .stub(movieName: "foo"),
            .stub(movieName: "bar"),
            .stub(movieName: "baz")
        ])
        services.mockAPI.mockResponse = .success(mockResponse)
        
        // When
        try? await viewModel.setup()
        
        // Then
        XCTAssertEqual(viewModel.movies[0].name, "Silent Hill")
        XCTAssertEqual(viewModel.movies[1].name, "foo")
        XCTAssertEqual(viewModel.newReleases[0].name, "bar")
        XCTAssertEqual(viewModel.newReleases[1].name, "baz")
        XCTAssertEqual(viewModel.movies.count, 2)
        XCTAssertEqual(viewModel.newReleases.count, 2)
    }
    
    func testSetupFailure() async {
        // Given
        services.mockAPI.mockResponse = .failure(MockAPIError.mockError)
        
        // When
        try? await viewModel.setup()
        
        // Then
        XCTAssertTrue(viewModel.movies.isEmpty)
        XCTAssertTrue(viewModel.newReleases.isEmpty)
    }
    
    func testSelectMovie() async {
        // Given
        viewModel.movies = [
            .stub(item: .stub(movieName: "Foo"), type: .movies),
            .stub(item: .stub(movieName: "Bar"), type: .movies)
        ]
        viewModel.newReleases = [
            .stub(item: .stub(movieName: "Baz"), type: .new),
            .stub(item: .stub(movieName: "Silent Hill"), type: .new)
        ]
        
        // When
        viewModel.selectMovie(at: 1, type: .movies)
        
        // Then
        XCTAssertEqual(coordinator.invocations[0], .showDetails(viewModel.movies[1]))
    }
    
    func testSelectNewMovie() async {
        // Given
        viewModel.movies = [
            .stub(item: .stub(movieName: "Foo"), type: .movies)
        ]
        viewModel.newReleases = [
            .stub(item: .stub(movieName: "Baz"), type: .new),
            .stub(item: .stub(movieName: "Bar"), type: .new),
            .stub(item: .stub(movieName: "Silent Hill"), type: .new)
        ]
        
        // When
        viewModel.selectMovie(at: 2, type: .new)
        
        // Then
        XCTAssertEqual(coordinator.invocations[0], .showDetails(viewModel.newReleases[2]))
    }
    
    func testReadMore() async {
        // Given
        viewModel.movies = [
            .stub(item: .stub(movieName: "Foo"), type: .movies)
        ]
        viewModel.newReleases = [
            .stub(item: .stub(movieName: "Baz"), type: .new),
            .stub(item: .stub(movieName: "Bar"), type: .new),
            .stub(item: .stub(movieName: "Silent Hill"), type: .new)
        ]
        
        // When
        viewModel.readMore()
        
        // Then
        XCTAssertEqual(coordinator.invocations[0], .showDetails(viewModel.newReleases[2]))
    }
    
    func testRegisterScreen() {
        // Given
        let promotionView = MockPromotionView()
        promotionView.screenName = "test screen name"
        services.mockSDKStatusManager.isSDKInitialised.send(true)
        let expectedPromoResult = PromotionResult(code: .accepted, value: ["foo": "bar"])
        services.mockPromotionService.setScreenNameResult = expectedPromoResult
        
        // When
        viewModel.registerScreen(promotionView)
        
        // Then
        XCTAssertEqual(services.mockPromotionService.invocations, [
            .setScreenName("test screen name")
        ])
        XCTAssertEqual(coordinator.invocations, [
            .handlePromotion(expectedPromoResult)
        ])
    }
}
