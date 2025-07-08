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
    private let session: URLSession

    init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        config.waitsForConnectivity = true
        config.networkServiceType = .responsiveData
        self.session = URLSession(configuration: config)

        // Configure cache limits
        cache.countLimit = 100
        cache.totalCostLimit = 50 * 1024 * 1024 // 50MB
    }

    func loadImageData(from url: URL) async throws -> Data {
        if let cachedImage = cache.object(forKey: url.absoluteString as NSString) {
            return cachedImage as Data
        }

        let data = try await loadWithRetry(url: url, maxRetries: 3)

        cache.setObject(data as NSData, forKey: url.absoluteString as NSString)
        return data
    }

    private func loadWithRetry(url: URL, maxRetries: Int, currentRetry: Int = 0) async throws -> Data {
        do {
            let (data, response) = try await session.data(from: url)

            // Check for valid HTTP response
            if let httpResponse = response as? HTTPURLResponse {
                guard 200...299 ~= httpResponse.statusCode else {
                    throw ImageLoadError.invalidResponse(httpResponse.statusCode)
                }
            }

            return data
        } catch {
            if currentRetry < maxRetries {
                // Wait before retrying (exponential backoff)
                let delay = min(pow(2.0, Double(currentRetry)), 10.0)
                try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                return try await loadWithRetry(url: url, maxRetries: maxRetries, currentRetry: currentRetry + 1)
            } else {
                throw error
            }
        }
    }
}

enum ImageLoadError: Error, LocalizedError {
    case invalidResponse(Int)

    var errorDescription: String? {
        switch self {
        case .invalidResponse(let code):
            return "Invalid HTTP response: \(code)"
        }
    }
}
