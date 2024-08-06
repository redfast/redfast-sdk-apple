//
//  MockPromotionService.swift
//  RedflixTests
//
//  Created by Volodymyr Mykhailiuk on 31.05.2024.
//

import Foundation
import RedFast
@testable import Redflix

final class MockPromotionService: PromotionServiceProtocol {
    enum Invocation: Equatable {
        case initPromotion(_ appId: String, _ userId: String, _ deviceType: String)
        case setScreenName(String)
        case getInlines(InlineType)
        case buttonClick(_ name: String, buttonId: String?)
        case onInlineClick(String?)
        case registerDeviceToken(String)
        case showModal(String)
        case purchase(String)
        case showDebugView
    }
    
    var invocations: [Invocation] = []
    var inlines: [Prompt] = []
    var initPromotionResult = PromotionResult.init(code: .disabled, value: nil, meta: nil)
    var setScreenNameResult = PromotionResult.init(code: .disabled, value: nil, meta: nil)
    var buttonClickResult = PromotionResult.init(code: .disabled, value: nil, meta: nil)
    var onInlineClickResult = PromotionResult.init(code: .disabled, value: nil, meta: nil)
    var showModalResult = PromotionResult.init(code: .disabled, value: nil, meta: nil)
    var purchaseResult = IapResult.successful
    
    func initPromotion(appId: String, userId: String, deviceType: String, onComplete: ((PromotionResult) -> Void)?) {
        invocations.append(.initPromotion(appId, userId, deviceType))
        onComplete?(initPromotionResult)
    }
    
    func setScreenName(_ parent: PromotionViewProtocol, onComplete: @escaping (PromotionResult) -> Void) {
        invocations.append(.setScreenName(parent.name))
        onComplete(setScreenNameResult)
    }
    
    func getInlines(_ type: InlineType) -> [Prompt] {
        invocations.append(.getInlines(type))
        return inlines
    }
    
    func buttonClick(_ parent: PromotionViewProtocol, buttonId: String?, _ onComplete: @escaping (PromotionResult) -> Void) {
        invocations.append(.buttonClick(parent.name, buttonId: buttonId))
        onComplete(buttonClickResult)
    }
    
    func onInlineClick(prompt: Prompt, _ onComplete: @escaping(PromotionResult) -> Void) {
        
        invocations.append(.onInlineClick(prompt.properties.appleInappProductId))
        onComplete(onInlineClickResult)
    }
    
    func registerDeviceToken(_ deviceToken: String) {
        invocations.append(.registerDeviceToken(deviceToken))
    }
    
    func showModal(on parent: PromotionViewProtocol, id: String, _ onComplete: @escaping(PromotionResult) -> Void) {
        invocations.append(.showModal(id))
        onComplete(showModalResult)
    }
    
    func purchase(_ productId: String, _ onComplete: @escaping (IapResult) -> Void) {
        invocations.append(.purchase(productId))
        onComplete(purchaseResult)
    }
    
    func showDebugView(_ viewController: PromotionViewProtocol) {
        invocations.append(.showDebugView)
    }
}
