//
//  ProfileViewModel.swift
//  Redflix
//
//  Created by Volodymyr Mykhailiuk on 23.05.2024.
//

import Foundation
import Combine

final class ProfileViewModel {
    
    enum AlertState {
        case cancelSubscription
    }
    
    enum ProfileMessage {
        case emptyFirstName
        case emptySecondName
        case invalidEmail
        case successSubmission
        case offerAccepted
        case subscriptionCanceled
        
        var title: String {
            switch self {
            case .emptyFirstName, .emptySecondName, .invalidEmail:
                return "Error"
            case .successSubmission, .offerAccepted, .subscriptionCanceled:
                return "Thank you!"
            }
        }
        
        var body: String {
            switch self {
            case .emptyFirstName:
                return "Please fill in your first name"
            case .emptySecondName:
                return "Please fill in your second name"
            case .invalidEmail:
                return "Please add an valid email"
            case .successSubmission:
                return "Your submission has been received!"
            case .offerAccepted:
                return "You gain 2 free months"
            case .subscriptionCanceled:
                return "Your subscription canceled"
            }
        }
    }
    
    // MARK: - Properties
    private var cancellable = Set<AnyCancellable>()
    @Published var profileMessage: ProfileMessage?
    
    // MARK: - Services
    private let promotionService: PromotionServiceProtocol
    private let sdkStatusManager: SDKStatusManaging
    private let emailValidator: EmailValidatorProtocol
    weak var coordinator: TabCoordinatorProtocol?
    
    init(services: ServiceLocating, coordinator: TabCoordinatorProtocol) {
        self.promotionService = services.resolve()
        self.sdkStatusManager = services.resolve()
        self.emailValidator = services.resolve()
        self.coordinator = coordinator
    }
    
    func change(firstName: String?, secondName: String?, phone: String?, email: String?) {
        guard let firstName, !firstName.isEmpty else {
            profileMessage = .emptyFirstName
            return
        }
        guard let secondName, !secondName.isEmpty else {
            profileMessage = .emptySecondName
            return
        }
        
        guard emailValidator.isValidEmail(email) else {
            profileMessage = .invalidEmail
            return
        }
        
        profileMessage = .successSubmission
    }
    
    func registerScreen(_ vc: PromotionViewProtocol) {
        sdkStatusManager.isSDKInitialised.sink { [weak self] isInitialised in
            guard let self, isInitialised else { return }
            self.promotionService.setScreenName(vc) {
                self.coordinator?.handlePromotion($0)
            }
        }.store(in: &cancellable)
    }
    
    func cancelSubscription(id: String?, vc: PromotionViewProtocol) {
        promotionService.buttonClick(vc, buttonId: id) { [weak self] result in
            guard let self else { return }
            switch result.code {
            case .accepted:
                profileMessage = .offerAccepted
            case .declined:
                profileMessage = .subscriptionCanceled
            default:
                profileMessage = .subscriptionCanceled
            }
        }
    }
    
    func billingHistory() {
        profileMessage = .successSubmission
    }
    
    func showDebugView(_ vc: PromotionViewProtocol) {
        promotionService.showDebugView(vc)
    }
}
