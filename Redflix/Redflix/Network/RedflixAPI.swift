//
//  RedflixAPI.swift
//  Redflix
//
//  Created by Volodymyr Mykhailiuk on 07.05.2024.
//

import Foundation

protocol RedflixAPIProtocol {
    func fetchMovieCollection(collectionId: String) async throws -> MovieCollectionResponse
}

final class RedflixAPI: RedflixAPIProtocol {
    
    // MARK: - Properties
    private let networkManager: NetworkManagerProtocol
    private let baseUrl = "https://api.webflow.com/v2/"
    private var headers: [String: String] = [
        "Accept": "application/json",
        "accept-version": "1.0.0",
        "Authorization": "Bearer \(AppConstants.webflowBearerToken)"
    ]

    init(networkManager: NetworkManagerProtocol) {
        self.networkManager = networkManager
    }
    
    func fetchMovieCollection(collectionId: String) async throws -> MovieCollectionResponse {
        try await networkManager.request(
            method: .get,
            url: baseUrl + "collections/\(collectionId)/items",
            headers: self.headers,
            params: [:],
            of: MovieCollectionResponse.self
        )
    }
}
