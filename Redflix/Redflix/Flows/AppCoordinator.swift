//
//  AppCoordinator.swift
//  Redflix
//
//  Created by Volodymyr Mykhailiuk on 03.05.2024.
//

import UIKit
import Combine

protocol Coordinator {
    var navigationController: UINavigationController { get }
    
    func start()
}

final class AppCoordinator: Coordinator {
    var parentCoordinator: Coordinator?
    var children: [Coordinator] = []
    var navigationController: UINavigationController
    private let window: UIWindow
    private let deepLinkParser: DeepLinkServiceProtocol
    private let sdkStatusManager: SDKStatusManaging
    private let userDefaultsService: UserDefaultsServiceProtocol
    private let promotionService: PromotionServiceProtocol
    private var unprocessedDeepLink: URL?
    private var cancellable = Set<AnyCancellable>()
    
    var mainCoordinator: MainTabCoordinator? {
        children.first { $0 is MainTabCoordinator } as? MainTabCoordinator
    }
    
    init(window: UIWindow) {
        self.window = window
        self.navigationController = UINavigationController()
        self.deepLinkParser = ServiceLocator.shared.resolve()
        self.sdkStatusManager = ServiceLocator.shared.resolve()
        self.userDefaultsService = ServiceLocator.shared.resolve()
        self.promotionService = ServiceLocator.shared.resolve()
    }
    
    func start() {
        if AppConstants.appId.isEmpty || AppConstants.userId.isEmpty || AppConstants.webflowBearerToken.isEmpty {
            fatalError("Please contact the customer support to get the appId, userId and webflowBearerToken.")
        }
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        startMainFlow()
    }
    
    func startMainFlow() {
        let mainCoordinator = MainTabCoordinator(navigationController)
        mainCoordinator.start()
        children.append(mainCoordinator)
        initSDK()
    }
    
    func handleDeepLink(_ deepLink: URL) {
        let type = deepLinkParser.parseDeepLink(url: deepLink)
        
        if sdkStatusManager.isSDKInitialised.value == false {
            unprocessedDeepLink = deepLink
            return
        }
        
        switch type {
        case .home:
            mainCoordinator?.selectTab(.home)
        case .genres:
            mainCoordinator?.selectTab(.genres)
        case .latest:
            mainCoordinator?.selectTab(.latest)
        case .profile:
            mainCoordinator?.selectTab(.profile)
        case .web(let urlString):
            openURL(URL(string: urlString))
        case .prompt(let id):
            mainCoordinator?.showModal(id: id)
        case .inAppPurchase(let sku):
            Task {
                try? await mainCoordinator?.startPurchase(sku: sku)
            }
        default:
            break
        }
    }
    
    func registerToken(_ token: String) {
        let lastUploadedToken: String? = userDefaultsService.retrieveValue(for: .apnLastUploadedDeviceToken)
        if token == lastUploadedToken {
            return
        }
        
        sdkStatusManager.isSDKInitialised.sink { [weak self] isInitialised in
            guard let self, isInitialised else { return }
            Task {
                do {
                    try await self.promotionService.registerDeviceToken(token)
                    self.userDefaultsService.saveValue(token, for: .apnLastUploadedDeviceToken)
                } catch let error {
                    print("Can not upload the token: \(error.localizedDescription)")
                }
            }
        }.store(in: &cancellable)
    }
    
    private func openURL(_ url: URL?) {
        guard let url else { return }
        UIApplication.shared.open(url)
    }
    
    private func initSDK() {
        var deviceType = "ios"
#if os(tvOS)
        deviceType = "tv_os"
#endif
        
        promotionService.initPromotion(appId: AppConstants.appId, userId: AppConstants.userId, deviceType: deviceType) { [weak self] result in
            guard result.code == .accepted else {
                return
            }
            self?.sdkStatusManager.isSDKInitialised.value = true
            
            if let deepLink = self?.unprocessedDeepLink {
                self?.unprocessedDeepLink = nil
                DispatchQueue.main.async {
                    self?.handleDeepLink(deepLink)
                }
            }
        }
    }
}
