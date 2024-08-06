//
//  ImageLoader.swift
//  Redflix
//
//  Created by Volodymyr Mykhailiuk on 09.05.2024.
//

import Foundation

protocol ImageLoaderProtocol {
    func loadImageData(from url: URL) async throws -> Data
}

final class ImageLoader: ImageLoaderProtocol {
    private let cache = NSCache<NSString, NSData>()
    
    func loadImageData(from url: URL) async throws -> Data {
        if let cachedImage = cache.object(forKey: url.absoluteString as NSString) {
            return cachedImage as Data
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        
        cache.setObject(data as NSData, forKey: url.absoluteString as NSString)
        return data
    }
}
