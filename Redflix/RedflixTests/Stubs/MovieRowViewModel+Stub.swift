//
//  MovieRowViewModel+Stub.swift
//  RedflixTests
//
//  Created by Volodymyr Mykhailiuk on 20.05.2024.
//

import Foundation
@testable import Redflix

extension MovieRowViewModel {
    static func stub(
        item: MovieCollectionResponse.MovieItem,
        type: HomeCollectionViewType = .movies,
        imageLoader: MockImageLoader = MockImageLoader(),
        dateFormatter: MockDateFormatter = MockDateFormatter()
    ) -> MovieRowViewModel {
        return MovieRowViewModel(
            with: item,
            type: type,
            imageLoader: imageLoader, 
            dateFormatter: dateFormatter
        )
    }
}

extension MovieRowViewModel: Equatable {
    public static func == (lhs: Redflix.MovieRowViewModel, rhs: Redflix.MovieRowViewModel) -> Bool {
        lhs.name == rhs.name
        && lhs.director == rhs.director
        && lhs.duration == rhs.duration
        && lhs.rating == rhs.rating
        && lhs.starRating == rhs.starRating
        && lhs.category == rhs.category
        && lhs.shortDescription == rhs.shortDescription
        && lhs.landscapeImageURL == rhs.landscapeImageURL
        && lhs.portraitImageURL == rhs.portraitImageURL
    }
}

