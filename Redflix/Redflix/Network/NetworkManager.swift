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
        
        let (data, _) = try await URLSession.shared.data(for: request)
        return try decoder.decode(T.self, from: data)
    }
}
