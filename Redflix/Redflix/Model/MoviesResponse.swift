//
//  MovieCollectionResponse.swift
//  Redflix
//
//  Created by sbonilla on 23/12/25.
//

import Foundation

struct MovieCollectionResponse: Decodable {
    let items: [Movie]
}

struct Movie: Decodable {
    let createdOn: String
    let local: Bool?
    let fieldData: MovieData?
    
    enum CodingKeys: String, CodingKey {
        case createdOn = "createdOn"
        case local
        case fieldData = "fieldData"
    }
}

struct MovieData: Decodable, Hashable, Equatable {
    
    let id: UUID? = UUID()
    let name: String?
    let director: String?
    let duration: String?
    let rating: String?
    let categoryId: String?
    let shortDescription: String?
    let landscape: ImageData?
    let portrait: ImageData?
    
    enum CodingKeys: String, CodingKey {
        case name
        case director
        case duration
        case rating
        case categoryId = "category"
        case shortDescription = "short-description"
        case landscape = "thumbnail-landscape"
        case portrait = "thumbnail-portrait"
    }
    
    var portraitURL: URL? {
        guard let portraitURLString = self.portrait?.url else { return nil }
        return URL(string: portraitURLString)
    }
    
    var landscapeURL: URL? {
        guard let landscapeURLString = self.landscape?.url else { return nil }
        return URL(string: landscapeURLString)
    }
}

struct ImageData: Decodable, Hashable, Equatable {
    let url: String
}
