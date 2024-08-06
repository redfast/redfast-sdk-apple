//
//  GenresViewModelTests.swift
//  RedflixTests
//
//  Created by Volodymyr Mykhailiuk on 22.05.2024.
//

import XCTest
import RedFast
@testable import Redflix

final class GenresViewModelTests: XCTestCase {
    var viewModel: GenresViewModel!
    var services: MockServiceLocator!
    var coordinator: MockTabCoordinator!
    private let imageURL1 = "https://cdn.lifeofpix.com/368587/_w1800/368628/lifeofpix-368587368628.webp"
    private let imageURL2 = "https://cdn.lifeofpix.com/238472/_w1800/368820/lifeofpix-238472368820.webp"
    
    override func setUp() {
        super.setUp()
        services = MockServiceLocator()
        services.mockImageLoader = MockImageLoader()
        services.mockAPI = MockRedflixAPI()
        services.mockDate = MockDateFormatter()
        services.mockPromotionService = MockPromotionService()
        services.mockSDKStatusManager = MockSDKStatusManager()
        coordinator = MockTabCoordinator()
        viewModel = GenresViewModel(services: services, coordinator: coordinator)
    }
    
    override func tearDown() {
        viewModel = nil
        services = nil
        coordinator = nil
        super.tearDown()
    }
    
    func testSetupSuccessWithGroupedAndSortedMovies() async {
        // Given
        let mockResponse = MovieCollectionResponse(items: [
            .stub(movieName: "Movie A", categoryId: MovieRowViewModel.Category.horror.rawValue),
            .stub(movieName: "Movie B", categoryId: MovieRowViewModel.Category.adventure.rawValue),
            .stub(movieName: "Movie C", categoryId: MovieRowViewModel.Category.thriller.rawValue),
            .stub(movieName: "Movie D", categoryId: MovieRowViewModel.Category.horror.rawValue),
            .stub(movieName: "Movie E", categoryId: MovieRowViewModel.Category.horror.rawValue),
            .stub(movieName: "Movie F", categoryId: MovieRowViewModel.Category.thriller.rawValue),
        ])
        services.mockAPI.mockResponse = .success(mockResponse)
        
        // When
        do {
            try await viewModel.setup()
        } catch {
            XCTFail("Expected setup to succeed, but it failed with error: \(error)")
        }
        
        // Then
        XCTAssertEqual(viewModel.movies.count, 3)
        XCTAssertEqual(viewModel.movies[0].count, 3)
        XCTAssertEqual(viewModel.movies[1].count, 2)
        XCTAssertEqual(viewModel.movies[2].count, 1)
        
        XCTAssertEqual(viewModel.movies[0][0].name, "Movie A")
        XCTAssertEqual(viewModel.movies[0][0].category, .horror)
        XCTAssertEqual(viewModel.movies[0][1].name, "Movie D")
        XCTAssertEqual(viewModel.movies[0][1].category, .horror)
        XCTAssertEqual(viewModel.movies[0][2].name, "Movie E")
        XCTAssertEqual(viewModel.movies[0][2].category, .horror)
        
        XCTAssertEqual(viewModel.movies[1][0].name, "Movie C")
        XCTAssertEqual(viewModel.movies[1][0].category, .thriller)
        XCTAssertEqual(viewModel.movies[1][1].name, "Movie F")
        XCTAssertEqual(viewModel.movies[1][1].category, .thriller)
        
        XCTAssertEqual(viewModel.movies[2][0].name, "Movie B")
        XCTAssertEqual(viewModel.movies[2][0].category, .adventure)
    }
    
    func testSetupSuccessWithEqualMoviesCountSortByCategoryName() async {
        // Given
        let mockResponse = MovieCollectionResponse(items: [
            .stub(movieName: "Movie A", categoryId: MovieRowViewModel.Category.horror.rawValue),
            .stub(movieName: "Movie B", categoryId: MovieRowViewModel.Category.adventure.rawValue),
            .stub(movieName: "Movie C", categoryId: MovieRowViewModel.Category.thriller.rawValue)
        ])
        services.mockAPI.mockResponse = .success(mockResponse)
        
        // When
        do {
            try await viewModel.setup()
        } catch {
            XCTFail("Expected setup to succeed, but it failed with error: \(error)")
        }
        
        // Then
        XCTAssertEqual(viewModel.movies.count, 3)
        XCTAssertEqual(viewModel.movies[0].count, 1)
        XCTAssertEqual(viewModel.movies[1].count, 1)
        XCTAssertEqual(viewModel.movies[2].count, 1)
        
        XCTAssertEqual(viewModel.movies[0][0].name, "Movie B")
        XCTAssertEqual(viewModel.movies[1][0].name, "Movie A")
        XCTAssertEqual(viewModel.movies[2][0].name, "Movie C")
    }
    
    func testSetupFailureWithEmptyMovies() async {
        // Given
        services.mockAPI.mockResponse = .failure(MockAPIError.mockError)
        
        // When
        do {
            try await viewModel.setup()
            XCTFail("Expected setup to fail, but it succeeded")
        } catch {
            // Expecting failure, no need to handle
        }
        
        // Then
        XCTAssertTrue(viewModel.movies.isEmpty)
    }
    
    func testSelectMovie() {
        // Given
        let movies: [[MovieRowViewModel]] = [
            [.stub(item: .stub(movieName: "Movie B", categoryId: MovieRowViewModel.Category.scienceFiction.rawValue))],
            [
                .stub(item: .stub(movieName: "Movie A", categoryId: MovieRowViewModel.Category.scienceFiction.rawValue)),
                .stub(item: .stub(movieName: "Movie C", categoryId: MovieRowViewModel.Category.scienceFiction.rawValue))
            ]
        ]
        viewModel.state = .loaded(movies)
        
        // When
        viewModel.selectMovie(at: 1, row: 1)
        
        // Then
        guard case .loaded(let movies) = viewModel.state else {
            XCTFail()
            return
        }
        XCTAssertEqual(coordinator.invocations[0], .showDetails(movies[1][1]))
    }
    
    func testRegisterScreen() {
        // Given
        let promotionView = MockPromotionView()
        promotionView.screenName = "test screen name"
        services.mockSDKStatusManager.isSDKInitialised.send(true)
        let expectedPromoResult = PromotionResult(code: .accepted, value: ["foo": "bar"])
        services.mockPromotionService.setScreenNameResult = expectedPromoResult
        
        // When
        viewModel.registerScreen(for: promotionView, type: .redflixBanner)
        
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
