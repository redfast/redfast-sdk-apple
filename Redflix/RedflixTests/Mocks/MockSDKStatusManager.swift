//
//  MockSDKStatusManager.swift
//  RedflixTests
//
//  Created by Volodymyr Mykhailiuk on 31.05.2024.
//

import Foundation
import Combine
@testable import Redflix

final class MockSDKStatusManager: SDKStatusManaging {
    var isSDKInitialised: CurrentValueSubject<Bool, Never> = .init(false)
}

