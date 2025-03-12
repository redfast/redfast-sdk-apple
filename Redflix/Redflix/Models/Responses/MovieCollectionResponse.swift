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
        let createdOn: String
        let local: Bool?
        let fieldData: FieldData?

        struct FieldData: Decodable {
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
        }

        enum CodingKeys: String, CodingKey {
            case createdOn = "createdOn"
            case local
            case fieldData = "fieldData"
        }
    }

    struct ImageData: Decodable {
        let url: String
    }
}
