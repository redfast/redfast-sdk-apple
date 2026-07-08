//
//  HomeViewModel.swift
//  Redflix
//
//  Created by sbonilla on 23/12/25.
//

import Combine
import SwiftUI


class HomeViewModel: BaseViewModel, ObservableObject {
    
    @Published var isLoading: Bool = false
    @Published var movies: [MovieData] = []
    @Published var releases: [MovieData] = []
    @Published var highlightMovie: MovieData?
    
    func fetchMovies() async {
        let collectionId = AppConstants.collectionId
        do {
            let response: MovieCollectionResponse = try await networkManager
                .request(url: baseURL + "collections/\(collectionId)/items",
                         headers: headers)
            let items = response.items.compactMap{ $0.fieldData }
            let middleIndex = items.count / 2
            self.movies = Array(items[..<middleIndex])
            self.releases = Array(items[middleIndex...])
            self.highlightMovie = items[4]
        } catch {
            print("Error fetching movies: \(error)")
        }
    }
}
