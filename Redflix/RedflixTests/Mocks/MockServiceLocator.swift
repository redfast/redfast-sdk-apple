//
//  MockServiceLocator.swift
//  RedflixTests
//
//  Created by Volodymyr Mykhailiuk on 15.05.2024.
//

import Foundation
@testable import Redflix

final class MockServiceLocator: ServiceLocating {
    var mockImageLoader: MockImageLoader!
    var mockAPI: MockRedflixAPI!
    var mockDate: MockDateFormatter!
    var mockEmailValidator: MockEmailValidator!
    var mockPromotionService: MockPromotionService!
    var mockSDKStatusManager: MockSDKStatusManager!
    var mockUserDefaultsService: MockUserDefaultsService!

    func resolve<T>() -> T {
        if let mock = mockImageLoader as? T {
            return mock
        }
        if let mock = mockAPI as? T {
            return mock
        }
        if let mock = mockDate as? T {
            return mock
        }
        if let mock = mockEmailValidator as? T {
            return mock
        }
        if let mock = mockPromotionService as? T {
            return mock
        }
        if let mock = mockSDKStatusManager as? T {
            return mock
        }
        if let mock = mockUserDefaultsService as? T {
            return mock
        }

        preconditionFailure("No service found")
    }
}
