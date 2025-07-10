//
//  NetworkManager.swift
//  Redflix
//
//  Created by Volodymyr Mykhailiuk on 07.05.2024.
//

import Foundation

protocol NetworkManagerProtocol: AnyObject {
    func request<T: Decodable>(
        method: HTTPMethod,
        url: String,
        headers: [String: String],
        params: [String: Any],
        of type: T.Type
    ) async throws -> T
}

actor NetworkManager: NetworkManagerProtocol {

    private lazy var decoder = JSONDecoder()
    private let session: URLSession

    init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        config.waitsForConnectivity = true
        config.networkServiceType = .responsiveData
        self.session = URLSession(configuration: config)
    }

    func request<T: Decodable>(
        method: HTTPMethod,
        url: String,
        headers: [String: String],
        params: [String: Any],
        of type: T.Type
    ) async throws -> T {
        guard var urlComponents = URLComponents(string: url) else {
            throw ApiError.invalidURL
        }

        switch method {
        case .get:
            var queryItems = [URLQueryItem]()
            for (key, value) in params {
                if let encodedValue = "\(value)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                    queryItems.append(URLQueryItem(name: key, value: encodedValue))
                }
            }
            if !queryItems.isEmpty {
                urlComponents.queryItems = queryItems
            }
        case .post:
            preconditionFailure("Needs to be implemented")
        }

        guard let url = urlComponents.url else {
            throw ApiError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        for (key, value) in headers {
            request.addValue(value, forHTTPHeaderField: key)
        }

        request.cachePolicy = .reloadIgnoringCacheData

        let data = try await requestWithRetry(request: request, maxRetries: 3)
        return try decoder.decode(T.self, from: data)
    }

    private func requestWithRetry(request: URLRequest, maxRetries: Int, currentRetry: Int = 0) async throws -> Data {
        do {
            let (data, response) = try await session.data(for: request)

            // Check for valid HTTP response
            if let httpResponse = response as? HTTPURLResponse {
                guard 200...299 ~= httpResponse.statusCode else {
                    throw ApiError.invalidResponse(httpResponse.statusCode)
                }
            }

            return data
        } catch {
            if currentRetry < maxRetries && shouldRetry(error: error) {
                // Wait before retrying (exponential backoff)
                let delay = min(pow(2.0, Double(currentRetry)), 10.0)
                try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                return try await requestWithRetry(request: request, maxRetries: maxRetries, currentRetry: currentRetry + 1)
            } else {
                throw error
            }
        }
    }

    private func shouldRetry(error: Error) -> Bool {
        if let urlError = error as? URLError {
            switch urlError.code {
            case .networkConnectionLost, .timedOut, .cannotConnectToHost, .cannotFindHost, .dnsLookupFailed:
                return true
            default:
                return false
            }
        }
        return false
    }
}
