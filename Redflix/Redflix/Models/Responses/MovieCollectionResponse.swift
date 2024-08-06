//
//  MovieCollectionResponse.swift
//  Redflix
//
//  Created by Volodymyr Mykhailiuk on 07.05.2024.
//

import Foundation

struct MovieCollectionResponse: Decodable {
    let items: [MovieItem]
    
    struct MovieItem: Decodable {
        let name: String?
        let director: String?
        let duration: String?
        let rating: String?
        let categoryId: String?
        let shortDescription: String?
        let landscape: ImageData?
        let portrait: ImageData?
        let createdOn: String
        let local: Bool?
        
        enum CodingKeys: String, CodingKey {
            case name
            case director
            case duration
            case rating
            case categoryId = "category"
            case shortDescription = "short-description"
            case landscape = "thumbnail-landscape"
            case portrait = "thumbnail-portrait"
            case createdOn = "created-on"
            case local
        }
    }
    
    struct ImageData: Decodable {
        let url: String
    }
}
