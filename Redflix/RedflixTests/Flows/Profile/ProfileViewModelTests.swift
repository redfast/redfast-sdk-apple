//
//  ProfileViewModelTests.swift
//  RedflixTests
//
//  Created by Volodymyr Mykhailiuk on 27.05.2024.
//

import XCTest
import RedFast
@testable import Redflix

final class ProfileViewModelTests: XCTestCase {
    var services: MockServiceLocator!
    var viewModel: ProfileViewModel!
    var coordinator: MockTabCoordinator!
    
    override func setUp() {
        super.setUp()
        services = MockServiceLocator()
        services.mockEmailValidator = MockEmailValidator()
        services.mockSDKStatusManager = MockSDKStatusManager()
        services.mockPromotionService = MockPromotionService()
        coordinator = MockTabCoordinator()
        viewModel = ProfileViewModel(services: services, coordinator: coordinator)
    }
    
    override func tearDown() {
        services = nil
        viewModel = nil
        super.tearDown()
    }
    
    func testChangeWithEmptyFirstName() {
        // When
        viewModel.change(firstName: "", secondName: "Last", phone: "1234567890", email: "test@example.com")
        
        // Then
        XCTAssertEqual(viewModel.profileMessage, .emptyFirstName)
    }
    
    func testChangeWithEmptySecondName() {
        // When
        viewModel.change(firstName: "First", secondName: "", phone: "1234567890", email: "test@example.com")
        
        // Then
        XCTAssertEqual(viewModel.profileMessage, .emptySecondName)
    }
    
    func testChangeWithInvalidEmail() {
        // Given
        services.mockEmailValidator.isValidEmailResult = false
        
        // When
        viewModel.change(firstName: "First", secondName: "Last", phone: "1234567890", email: "invalid email")
        
        // Then
        XCTAssertEqual(viewModel.profileMessage, .invalidEmail)
    }
    
    func testChangeWithValidData() {
        // Given
        services.mockEmailValidator.isValidEmailResult = true
        
        // When
        viewModel.change(firstName: "First", secondName: "Last", phone: "1234567890", email: "test@example.com")
        
        // Then
        XCTAssertEqual(viewModel.profileMessage, .successSubmission)
    }
    
    func testBillingHistory() {
        // When
        viewModel.billingHistory()
        
        // Then
        XCTAssertEqual(viewModel.profileMessage, .successSubmission)
    }
    
    func testRegisterScreen() {
        // Given
        let promotionView = MockPromotionView()
        promotionView.screenName = "test screen name"
        services.mockSDKStatusManager.isSDKInitialised.send(true)
        let expectedPromoResult = PromotionResult(code: .accepted, value: ["foo": "bar"])
        services.mockPromotionService.setScreenNameResult = expectedPromoResult
        
        // When
        viewModel.registerScreen(promotionView)
        
        // Then
        XCTAssertEqual(services.mockPromotionService.invocations, [
            .setScreenName("test screen name")
        ])
        XCTAssertEqual(coordinator.invocations, [
            .handlePromotion(expectedPromoResult)
        ])
    }
    
    func testCancelSubscriptionAccepted() {
        // Given
        let promotionView = MockPromotionView()
        promotionView.screenName = "test screen name"
        services.mockPromotionService.buttonClickResult = .init(code: .accepted, value: nil, meta: nil)

        // When
        viewModel.cancelSubscription(id: "Foo", vc: promotionView)
        
        // Then
        XCTAssertEqual(services.mockPromotionService.invocations, [.buttonClick("test screen name", buttonId: "Foo")])
        XCTAssertEqual(viewModel.profileMessage, .offerAccepted)
    }
    
    func testCancelSubscriptionDeclined() {
        // Given
        let promotionView = MockPromotionView()
        promotionView.screenName = "test screen name"
        services.mockPromotionService.buttonClickResult = .init(code: .declined, value: nil, meta: nil)

        // When
        viewModel.cancelSubscription(id: "Foo", vc: promotionView)
        
        // Then
        XCTAssertEqual(viewModel.profileMessage, .subscriptionCanceled)
    }
    
    func testShowSettings() {
        // Given
        let promotionView = MockPromotionView()
        promotionView.screenName = "test screen name"

        // When
        viewModel.showDebugView(promotionView)
        
        // Then
        XCTAssertEqual(services.mockPromotionService.invocations, [.showDebugView])
    }
}
