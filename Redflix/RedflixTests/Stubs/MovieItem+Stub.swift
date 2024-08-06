//
//  MovieItem+Stub.swift
//  RedflixTests
//
//  Created by Volodymyr Mykhailiuk on 13.05.2024.
//

@testable import Redflix

extension MovieCollectionResponse.MovieItem {
    static func stub(
        movieName: String = "",
        director: String = "",
        duration: String = "",
        rating: String = "",
        categoryId: String = "",
        shortDescription: String = "",
        landscape: MovieCollectionResponse.ImageData? = nil,
        portrait: MovieCollectionResponse.ImageData? = nil,
        createdOn: String = "",
        local: Bool = false
    ) -> MovieCollectionResponse.MovieItem {
        return MovieCollectionResponse.MovieItem(
            name: movieName,
            director: director,
            duration: duration,
            rating: rating,
            categoryId: categoryId,
            shortDescription: shortDescription,
            landscape: landscape,
            portrait: portrait, 
            createdOn: createdOn,
            local: local
        )
    }
}

extension MovieCollectionResponse.MovieItem: Equatable {
    public static func == (lhs: MovieCollectionResponse.MovieItem, rhs: MovieCollectionResponse.MovieItem) -> Bool {
        lhs.name == rhs.name 
        && lhs.director == rhs.director
        && lhs.duration == rhs.duration
        && lhs.rating == rhs.rating
        && lhs.categoryId == rhs.categoryId
        && lhs.shortDescription == rhs.shortDescription
        && lhs.director == rhs.director
        && lhs.landscape?.url == rhs.landscape?.url
        && lhs.portrait?.url == rhs.portrait?.url
        && lhs.local == rhs.local
    }
}
