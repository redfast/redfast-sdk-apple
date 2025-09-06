//
//  PromotionService.swift
//  Redflix
//
//  Created by Volodymyr Mykhailiuk on 28.05.2024.
//

import UIKit
import RedFast

enum InlineType: String {
    case redflixBanner = "redflix-banner"
    case redflixBannerPhone = "redflix-banner-phone"
}

protocol PromotionServiceProtocol {
    func initPromotion(appId: String, userId: String, deviceType: String, onComplete: ((PromotionResult) -> Void)?)
    func setScreenName(_ parent: PromotionViewProtocol, onComplete: @escaping (PromotionResult) -> Void)
    func getInlines(_ type: InlineType) -> [Prompt]
    func buttonClick(_ parent: PromotionViewProtocol, buttonId: String?, _ onComplete: @escaping (PromotionResult) -> Void)
    func onInlineClick(prompt: Prompt, _ onComplete: @escaping(PromotionResult) -> Void)
    func showModal(on parent: PromotionViewProtocol, id: String, _ onComplete: @escaping(PromotionResult) -> Void)
    func purchase(_ productId: String, _ onComplete: @escaping (IapResult) -> Void)
    func showDebugView(_ viewController: PromotionViewProtocol)
}

final class PromotionService: PromotionServiceProtocol {
    func initPromotion(appId: String, userId: String, deviceType: String, onComplete: ((PromotionResult) -> Void)?) {
        PromotionManager.initPromotion(appId: appId, userId: userId, deviceType: deviceType, onComplete: onComplete)
    }
    
    func setScreenName(_ parent: PromotionViewProtocol, onComplete: @escaping (PromotionResult) -> Void) {
        guard let vc = parent as? UIViewController else {
            preconditionFailure("Can't cast to UIViewController")
        }
        DispatchQueue.main.async {
            PromotionManager.setScreenName(vc, parent.name, onComplete: onComplete)
        }
    }
    
    func getInlines(_ type: InlineType) -> [Prompt] {
        PromotionManager.getInlines(type.rawValue)
    }
    
    func buttonClick(_ parent: PromotionViewProtocol, buttonId: String?, _ onComplete: @escaping (PromotionResult) -> Void) {
        guard let vc = parent as? UIViewController else {
            preconditionFailure("Can't cast to UIViewController")
        }
        PromotionManager.buttonClick(vc, buttonId: buttonId, onComplete)
    }
    
    func onInlineClick(prompt: Prompt, _ onComplete: @escaping(PromotionResult) -> Void) {
        PromotionManager.onInlineClick(prompt: prompt, onComplete)
    }

    func showModal(on parent: PromotionViewProtocol, id: String, _ onComplete: @escaping(PromotionResult) -> Void) {
        guard let vc = parent as? UIViewController else {
            preconditionFailure("Can't cast to UIViewController")
        }
        PromotionManager.showModal(on: vc, id: id, onComplete)
    }
    
    func purchase(_ productId: String, _ onComplete: @escaping (IapResult) -> Void) {
        PromotionManager.purchase(productId, onComplete)
    }
    
    func showDebugView(_ viewController: PromotionViewProtocol) {
        guard let vc = viewController as? UIViewController else {
            preconditionFailure("Can't cast to UIViewController")
        }
        PromotionManager.showDebugView(vc)
    }
}
