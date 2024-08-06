//
//  MockRedflixAPI.swift
//  RedflixTests
//
//  Created by Volodymyr Mykhailiuk on 13.05.2024.
//

@testable import Redflix

enum MockAPIError: Error {
    case mockError
}

final class MockRedflixAPI: RedflixAPIProtocol {
    enum MockResponse {
        case success(MovieCollectionResponse)
        case failure(Error)
    }
    
    var mockResponse: MockResponse = .success(MovieCollectionResponse(items: []))
    
    func fetchMovieCollection(collectionId: String) async throws -> MovieCollectionResponse {
        switch mockResponse {
        case .success(let response):
            return response
        case .failure(let error):
            throw error
        }
    }
}
