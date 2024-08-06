//
//  ServiceLocator.swift
//  Redflix
//
//  Created by Volodymyr Mykhailiuk on 14.05.2024.
//

import Foundation

protocol ServiceLocating {
    func resolve<T>() -> T
}

final class ServiceLocator: ServiceLocating {
    static let shared = ServiceLocator()
    private init() {}

    // MARK: Properties
    private lazy var services = [String: Any]()

    // MARK: Private
    private func typeName(_ some: Any) -> String {
        return (some is Any.Type) ? "\(some)" : "\(type(of: some))"
    }

    // MARK: Internal
    func register<T>(service: T) {
        let key = typeName(T.self)
        services[key] = service
    }

    func resolve<T>() -> T {
        let key = typeName(T.self)
        guard let service = services[key] as? T else {
            preconditionFailure("Service \(key) is not registered")
        }
        return service
    }
}
