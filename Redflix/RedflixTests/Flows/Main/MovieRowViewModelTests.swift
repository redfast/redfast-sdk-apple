//
//  MovieRowViewModelTests.swift
//  RedflixTests
//
//  Created by Volodymyr Mykhailiuk on 13.05.2024.
//

import XCTest
@testable import Redflix

final class MovieRowViewModelTests: XCTestCase {
    private var imageLoader: MockImageLoader!
    private var dateFormatter: MockDateFormatter!
    
    override func setUp() {
        imageLoader = MockImageLoader()
        dateFormatter = MockDateFormatter()
    }
    
    override func tearDown() {
        imageLoader = nil
        super.tearDown()
    }
    
    func testInitWithResponse() {
        // When
        let movieItem = movieItem(landscapeURL: "landscape_url", portraitURL: "portrait_url")
        dateFormatter.formattedMovieReleaseDate = "19 July, 2020"
        let viewModel = MovieRowViewModel(with: movieItem, type: .movies, imageLoader: imageLoader, dateFormatter: dateFormatter)
        
        // Then
        XCTAssertEqual(viewModel.name, "Test Movie")
        XCTAssertEqual(viewModel.director, "Test Director")
        XCTAssertEqual(viewModel.duration, "120 mins")
        XCTAssertEqual(viewModel.rating, 6.5)
        XCTAssertEqual(viewModel.starRating, 3)
        XCTAssertEqual(viewModel.category, .thriller)
        XCTAssertEqual(viewModel.shortDescription, "A test movie description")
        XCTAssertEqual(viewModel.landscapeImageURL?.absoluteString, "landscape_url")
        XCTAssertEqual(viewModel.portraitImageURL?.absoluteString, "portrait_url")
        XCTAssertEqual(viewModel.imageURL, viewModel.portraitImageURL)
        XCTAssertEqual(viewModel.releaseDate, "19 July, 2020")
        XCTAssertEqual(viewModel.collectionType, .movies)
    }
    
    func testLoadImageSuccess() async {
        // Given
        let expectedData = Data([0, 1, 0, 1])
        imageLoader.mockData = expectedData
        let movieItem = movieItem(landscapeURL: "landscape_url", portraitURL: "portrait_url")
        let viewModel = MovieRowViewModel(with: movieItem, type: .movies, imageLoader: imageLoader, dateFormatter: dateFormatter)
        
        // When
        let result = await viewModel.loadImageData()
        
        // Then
        XCTAssertEqual(result, expectedData)
    }
    
    func testLoadImageFailure() async {
        // Given
        let viewModel = MovieRowViewModel(with: movieItem(), type: .movies, imageLoader: imageLoader, dateFormatter: dateFormatter)
        
        // When
        let result = await viewModel.loadImageData()
        // Then
        XCTAssertEqual(result, nil)
    }
}

private extension MovieRowViewModelTests {
    func movieItem(landscapeURL: String? = nil, portraitURL: String? = nil) -> MovieCollectionResponse.MovieItem {
        MovieCollectionResponse.MovieItem(
            createdOn: "",
            local: false,
            fieldData: MovieCollectionResponse.MovieItem.FieldData(
                name: "Test Movie",
                director: "Test Director",
                duration: "120 mins",
                rating: "6,5",
                categoryId: "635c3e79a327a554fdd7a7f9",
                shortDescription: "A test movie description",
                landscape: landscapeURL != nil ? MovieCollectionResponse.ImageData(url: landscapeURL!) : nil,
                portrait: portraitURL != nil ? MovieCollectionResponse.ImageData(url: portraitURL!) : nil
            )
        )
    }
}

