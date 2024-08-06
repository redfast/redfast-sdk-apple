//
//  UserDefaultsService.swift
//  Redflix
//
//  Created by Volodymyr Mykhailiuk on 21.06.2024.
//

import Foundation

enum UserDefaultsKey: String {
    case apnLastUploadedDeviceToken
}

protocol UserDefaultsServiceProtocol {
    func saveValue<T: Codable>(_ value: T, for key: UserDefaultsKey)
    func retrieveValue<T: Codable>(for key: UserDefaultsKey) -> T?
}

final class UserDefaultsService: UserDefaultsServiceProtocol {
    private let userDefaults = UserDefaults.standard
    
    func saveValue<T: Codable>(_ value: T, for key: UserDefaultsKey) {
        do {
            let data = try JSONEncoder().encode(value)
            userDefaults.set(data, forKey: key.rawValue)
        } catch {
            print("Failed to encode and save value for key \(key.rawValue): \(error)")
        }
    }
    
    func retrieveValue<T: Codable>(for key: UserDefaultsKey) -> T? {
        guard let data = userDefaults.data(forKey: key.rawValue) else {
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
