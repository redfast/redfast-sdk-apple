//
//  MockUserDefaultsService.swift
//  RedflixTests
//
//  Created by GitHub Copilot on 07.07.2025.
//

import Foundation
@testable import Redflix

final class MockUserDefaultsService: UserDefaultsServiceProtocol {
    private var storage: [String: Any] = [:]

    func saveValue<T: Codable>(_ value: T, for key: UserDefaultsKey) {
        do {
            let data = try JSONEncoder().encode(value)
            storage[key.rawValue] = data
        } catch {
            print("Failed to encode and save value for key \(key.rawValue): \(error)")
        }
    }

    func retrieveValue<T: Codable>(for key: UserDefaultsKey) -> T? {
        guard let data = storage[key.rawValue] as? Data else {
            return nil
        }

        do {
            let value = try JSONDecoder().decode(T.self, from: data)
            return value
        } catch {
            print("Failed to decode value for key \(key.rawValue): \(error)")
            return nil
        }
    }
}
