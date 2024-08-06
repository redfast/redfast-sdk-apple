//
//  LatestViewModelTests.swift
//  RedflixTests
//
//  Created by Volodymyr Mykhailiuk on 15.05.2024.
//

import XCTest
import RedFast
@testable import Redflix

final class LatestViewModelTests: XCTestCase {
    var viewModel: LatestViewModel!
    var services: MockServiceLocator!
    var coordinator: MockTabCoordinator!
    private let imageURL = "https://buffer.com/cdn-cgi/image/w=1000,fit=contain,q=90,f=auto/library/content/images/size/w600/2023/10/free-images.jpg"
    
    override func setUp() {
        services = MockServiceLocator()
        services.mockImageLoader = MockImageLoader()
        services.mockAPI = MockRedflixAPI()
        services.mockDate = MockDateFormatter()
        services.mockSDKStatusManager = MockSDKStatusManager()
        services.mockPromotionService = MockPromotionService()
        coordinator = MockTabCoordinator()
        viewModel = LatestViewModel(services: services, coordinator: coordinator, collectionId: "testCollection")
    }
    
    override func tearDown() {
        viewModel = nil
        services = nil
        coordinator = nil
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
        XCTAssertEqual(viewModel.latestMovies[0].name, "bar")
        XCTAssertEqual(viewModel.latestMovies[1].name, "baz")
        XCTAssertEqual(viewModel.latestMovies[2].name, "foo")
        XCTAssertEqual(viewModel.latestMovies[3].name, "Silent Hill")
    }
    
    func testSetupFailure() async {
        // Given
        services.mockAPI.mockResponse = .failure(MockAPIError.mockError)
        
        // When
        try? await viewModel.setup()
        
        // Then
        XCTAssertTrue(viewModel.latestMovies.isEmpty)
    }
    
    func testSelectMovie() {
        // Given
        let latestMovies: [MovieRowViewModel] = [
            .stub(item: .stub(movieName: "Foo")),
            .stub(item: .stub(movieName: "Bar")),
            .stub(item: .stub(movieName: "Baz")),
            .stub(item: .stub(movieName: "Silent Hill"))
        ]
        viewModel.state = .loaded(latestMovies)
        
        // When
        viewModel.selectMovie(at: 3)
        
        // Then
        guard case .loaded(let movies) = viewModel.state else {
            XCTFail()
            return
        }
        XCTAssertEqual(coordinator.invocations[0], .showDetails(movies[3]))
    }
    
    func testRegisterScreen() {
        // Given
        let promotionView = MockPromotionView()
        promotionView.screenName = "test screen name"
        services.mockSDKStatusManager.isSDKInitialised.send(true)
        let expectedPromoResult = PromotionResult(code: .accepted, value: ["foo": "bar"])
        services.mockPromotionService.setScreenNameResult = expectedPromoResult
        
        // When
        viewModel.registerScreen(promotionView, type: .redflixBanner)
        
        // Then
        XCTAssertEqual(services.mockPromotionService.invocations, [
            .setScreenName("test screen name"),
            .getInlines(.redflixBanner)
        ])
        XCTAssertEqual(coordinator.invocations, [
            .handlePromotion(expectedPromoResult)
        ])
    }
}
