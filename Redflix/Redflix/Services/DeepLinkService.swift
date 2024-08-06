//
//  DeepLinkService.swift
//  Redflix
//
//  Created by Volodymyr Mykhailiuk on 06.06.2024.
//

import Foundation

protocol DeepLinkServiceProtocol {
    func parseDeepLink(url: URL) -> DeepLinkType
}

enum DeepLinkType {
    case home
    case latest
    case genres
    case profile
    case prompt(promptId: String)
    case inAppPurchase(sku: String)
    case web(url: String)
    case unknown
}

final class DeepLinkService: DeepLinkServiceProtocol {
    
    func parseDeepLink(url: URL) -> DeepLinkType {
        guard let schemeRange = url.absoluteString.range(of: "redflix://") else {
            return .unknown
        }
        
        let pathComponents = url.absoluteString[schemeRange.upperBound...]
            .split(separator: "/")
            .map(String.init)
        
        switch pathComponents.first {
        case "home":
            return .home
        case "latest":
            return .latest
        case "genres":
            return .genres
        case "profile":
            return .profile
        case "prompt":
            guard let promptRange = url.absoluteString.range(of: "redflix://prompt/") else {
                return .unknown
            }
            let id = String(url.absoluteString[promptRange.upperBound...])
            return .prompt(promptId: id)
        case "inapp":
            guard let inAppRange = url.absoluteString.range(of: "redflix://inapp/") else {
                return .unknown
            }
            let sku = String(url.absoluteString[inAppRange.upperBound...])
            return .inAppPurchase(sku: sku)
        case "web":
            guard let urlRange = url.absoluteString.range(of: "redflix://web/") else {
                return .unknown
            }
            let urlString = String(url.absoluteString[urlRange.upperBound...])
            return .web(url: urlString)
        default:
            return .unknown
        }
    }
}
