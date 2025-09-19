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
            createdOn: createdOn,
            local: local,
            fieldData: MovieCollectionResponse.MovieItem.FieldData(
                name: movieName,
                director: director,
                duration: duration,
                rating: rating,
                categoryId: categoryId,
                shortDescription: shortDescription,
                landscape: landscape,
                portrait: portrait
            )
        )
    }
}

extension MovieCollectionResponse.MovieItem: Equatable {
    public static func == (lhs: MovieCollectionResponse.MovieItem, rhs: MovieCollectionResponse.MovieItem) -> Bool {
        lhs.fieldData?.name == rhs.fieldData?.name
        && lhs.fieldData?.director == rhs.fieldData?.director
        && lhs.fieldData?.duration == rhs.fieldData?.duration
        && lhs.fieldData?.rating == rhs.fieldData?.rating
        && lhs.fieldData?.categoryId == rhs.fieldData?.categoryId
        && lhs.fieldData?.shortDescription == rhs.fieldData?.shortDescription
        && lhs.fieldData?.director == rhs.fieldData?.director
        && lhs.fieldData?.landscape?.url == rhs.fieldData?.landscape?.url
        && lhs.fieldData?.portrait?.url == rhs.fieldData?.portrait?.url
        && lhs.local == rhs.local
    }
}
