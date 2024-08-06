//
//  MockTabCoordinatorProtocol.swift
//  RedflixTests
//
//  Created by Volodymyr Mykhailiuk on 17.05.2024.
//

import Foundation
import UIKit
@testable import Redflix
import RedFast

final class MockTabCoordinator: TabCoordinatorProtocol {
    enum Invocation: Equatable {
        case showDetails(MovieRowViewModel)
        case startPurchase(String)
        case showLoading(Bool)
        case handlePromotion(PromotionResult)
    }
    
    var invocations: [Invocation] = []
    
    func selectTab(_ tab: TabType) {
        
    }
    
    func setSelectedIndex(_ index: Int) {
        
    }
    
    func showDetails(for vm: MovieRowViewModel) {
        invocations.append(.showDetails(vm))
    }
    
    func startPurchase(sku: String) async throws {
        invocations.append(.startPurchase(sku))
    }
    
    func showLoading(_ isLoading: Bool, completion: (() -> Void)?) {
        invocations.append(.showLoading(isLoading))
        completion?()
    }
    
    func handlePromotion(_ result: PromotionResult) {
        invocations.append(.handlePromotion(result))
    }
    
    var navigationController: UINavigationController = .init()
    
    func start() {
        
    }
}

extension PromotionResult: Equatable {
    public static func == (lhs: PromotionResult, rhs: PromotionResult) -> Bool {
        lhs.code == rhs.code
        && lhs.value == rhs.value
        && lhs.inAppProductId == rhs.inAppProductId
    }
}
