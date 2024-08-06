//
//  SDKStatusManager.swift
//  Redflix
//
//  Created by Volodymyr Mykhailiuk on 28.05.2024.
//

import Foundation
import Combine

protocol SDKStatusManaging {
    var isSDKInitialised: CurrentValueSubject<Bool, Never> { get set }
}

final class SDKStatusManager: SDKStatusManaging {
    var isSDKInitialised: CurrentValueSubject<Bool, Never> = .init(false)
}
