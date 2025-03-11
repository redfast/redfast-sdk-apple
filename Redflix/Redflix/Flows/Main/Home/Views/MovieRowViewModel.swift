//
//  MovieRowViewModel.swift
//  Redflix
//
//  Created by Volodymyr Mykhailiuk on 07.05.2024.
//

import UIKit

final class MovieRowViewModel {
    // TODO: temporary solution, need to get name from the server
    enum Category: String {
        case thriller = "635c3e79a327a554fdd7a7f9"
        case comedyHorror = "635c3e79a327a57ce5d7a800"
        case superhero = "635c3e79a327a517afd7a7fd"
        case horror = "635c3e79a327a508e1d7a803"
        case adventure = "635c3e79a327a52ac5d7a7fc"
        case scienceFiction = "635c3e79a327a537f2d7a7f8"
        case unknown
        
        var name: String {
            switch self {
            case .thriller:
                return "Thriller"
            case .comedyHorror:
                return "Comedy Horror"
            case .superhero:
                return "Superhero"
            case .horror:
                return "Horror"
            case .adventure:
                return "Adventure"
            case .scienceFiction:
                return "Science-Fiction"
            case .unknown:
                return "Other"
            }
        }
    }
    
    let name: String
    let director: String
    let duration: String
    let rating: Double
    let starRating: Int
    let category: Category
    let shortDescription: String
    let landscapeImageURL: URL?
    let portraitImageURL: URL?
    let releaseDate: String?
    let collectionType: HomeCollectionViewType
    let imageLoader: ImageLoaderProtocol
    
    var imageURL: URL? {
        switch collectionType {
        case .movies:
            return portraitImageURL
        case .new:
            return landscapeImageURL
        }
    }
    
    init(
        with response: MovieCollectionResponse.MovieItem,
        type: HomeCollectionViewType,
        imageLoader: ImageLoaderProtocol,
        dateFormatter: DateFormatting
    ) {
        name = response.fieldData?.name ?? ""
        director = response.fieldData?.director ?? ""
        duration = response.fieldData?.duration ?? ""
        let ratingStr = response.fieldData?.rating?.replacingOccurrences(of: ",", with: ".") ?? ""
        rating = Double(ratingStr) ?? 0
        starRating = Int(rating / 2)
        category = Category(rawValue: response.fieldData?.categoryId ?? "") ?? .unknown
        shortDescription = response.fieldData?.shortDescription ?? ""
        landscapeImageURL = URL(string: response.fieldData?.landscape?.url ?? "")
        portraitImageURL = URL(string: response.fieldData?.portrait?.url ?? "")
        let date = dateFormatter.getDateFromResponseString(string: response.createdOn)
        releaseDate = dateFormatter.formatMovieReleaseDate(from: date)
        collectionType = type
        self.imageLoader = imageLoader
    }
    
    func loadImageData() async -> Data? {
        guard let imageURL else {
            return nil
        }
        return try? await imageLoader.loadImageData(from: imageURL)
    }
}
