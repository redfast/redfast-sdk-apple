//
//  LatestViewModel.swift
//  Redflix
//

import SwiftUI
import Combine

class LatestViewModel: BaseViewModel, ObservableObject {

    @Published var isLoading: Bool = false
    @Published var movies: [MovieData] = []
    @Published var error: String? = nil

    func fetchMovies() async {
        isLoading = true
        error = nil
        let collectionId = AppConstants.collectionId
        do {
            let response: MovieCollectionResponse = try await networkManager
                .request(url: baseURL + "collections/\(collectionId)/items",
                         headers: headers)
            movies = response.items.compactMap { $0.fieldData }
        } catch {
            self.error = error.localizedDescription
            print("Error fetching latest movies: \(error)")
        }
        isLoading = false
    }
}
