//
//  MainTabCoordinator.swift
//  Redflix
//
//  Created by Volodymyr Mykhailiuk on 03.05.2024.
//

import UIKit
import RedFast

protocol TabCoordinatorProtocol: Coordinator, AnyObject {
    func selectTab(_ tab: TabType)
    func setSelectedIndex(_ index: Int)
    
    func showDetails(for vm: MovieRowViewModel)
    func startPurchase(sku: String) async throws
    func showLoading(_ isLoading: Bool, completion: (() -> Void)?)
    func handlePromotion(_ result: PromotionResult)
}

final class MainTabCoordinator: NSObject, TabCoordinatorProtocol {
    
    var childCoordinators: [Coordinator] = []
    
    private(set) var navigationController: UINavigationController
    private(set) var tabBarController: UITabBarController
    private var currentNavigationController: UINavigationController?
    private var tabNavigationControllers: [UINavigationController] = []
    private let services = ServiceLocator.shared
    private let promotionService: PromotionServiceProtocol
    private let purchaseManager: PurchaseManagerProtocol
    
    private lazy var loadingVC: UIViewController = {
        let loadingVC = LoadingViewController()
        loadingVC.modalPresentationStyle = .overCurrentContext
        loadingVC.modalTransitionStyle = .crossDissolve
        return loadingVC
    }()
    
    init(_ navigationController: UINavigationController) {
        self.promotionService = services.resolve()
        self.purchaseManager = services.resolve()
        self.navigationController = navigationController
        self.tabBarController = UITabBarController()
#if os(iOS)
        self.navigationController.setupBrandAppearance()
        self.navigationController.setNavigationBarHidden(true, animated: false)
#endif
    }
    
    func start() {
        let pages: [TabType] = [.home, .latest, .genres, .profile]
        let controllers: [UINavigationController] = pages.map {
            buildTabController($0)
        }
        tabNavigationControllers = controllers
        currentNavigationController = controllers.first
        
        prepareTabBarController(withTabControllers: controllers)
    }
    
    private func prepareTabBarController(withTabControllers tabControllers: [UIViewController]) {
        tabBarController.delegate = self
        tabBarController.setViewControllers(tabControllers, animated: true)
        tabBarController.selectedIndex = TabType.home.index
#if os(iOS)
        tabBarController.tabBar.isTranslucent = false
        tabBarController.tabBar.backgroundColor = AppColor.tabBarColor
        tabBarController.tabBar.barTintColor = AppColor.tabBarColor
        tabBarController.tabBar.tintColor = AppColor.tabBarItemSelected
        tabBarController.tabBar.unselectedItemTintColor = AppColor.tabBarItemUnselected
#endif
        navigationController.viewControllers = [tabBarController]
    }
    
    private func buildTabController(_ tab: TabType) -> UINavigationController {
        let navController = UINavigationController()
#if os(tvOS)
        navController.setNavigationBarHidden(true, animated: false)
#elseif os(iOS)
        navController.setNavigationBarHidden(false, animated: false)
        navController.setupBrandAppearance()
#endif
        
        navController.tabBarItem = UITabBarItem(
            title: tab.titleValue,
            image: UIImage(named: tab.iconName),
            tag: tab.index
        )
        
        var vc: UIViewController
        switch tab {
        case .home:
            vc = HomeViewAssembler.assembleModule(services: services, coordinator: self)
        case .latest:
            vc = LatestViewAssembler.assembleModule(services: services, coordinator: self)
        case .genres:
            vc = GenresViewAssembler.assembleModule(services: services, coordinator: self)
        case .profile:
            vc = ProfileViewAssembler.assembleModule(services: services, coordinator: self)
        }
        
        navController.viewControllers = [vc]
        return navController
    }
    
    func currentTab() -> TabType? {
        TabType(index: tabBarController.selectedIndex)
    }
    
    func selectTab(_ tab: TabType) {
        tabBarController.selectedIndex = tab.index
    }
    
    func setSelectedIndex(_ index: Int) {
        guard let tab = TabType(index: index) else { return }
        
        tabBarController.selectedIndex = tab.index
    }
    
    func showDetails(for vm: MovieRowViewModel) {
        let vc = MovieDetailsViewAssembler.assembleModule(
            services: services,
            coordinator: self,
            rowViewModel: vm
        )
        currentNavigationController?.pushViewController(vc, animated: true)
    }
    
    func startPurchase(sku: String) async throws {
        try await purchaseManager.loadProductsIfNeeded()
        try await purchaseManager.purchase(sku)
    }
    
    func showLoading(_ isLoading: Bool, completion: (() -> Void)?) {
        DispatchQueue.main.async {
            if isLoading {
                self.navigationController.present(self.loadingVC, animated: true, completion: completion)
            } else {
                self.navigationController.dismiss(animated: true, completion: completion)
            }
        }
    }
    
    func handlePromotion(_ result: PromotionResult) {
        if let sku = result.inAppProductId, result.code == .accepted {
            Task {
                try? await startPurchase(sku: sku)
            }
        }
    }
    
    func showModal(id: String) {
        currentNavigationController?.popToRootViewController(animated: false)
        guard let vc = currentNavigationController?.topViewController as? PromotionViewProtocol else {
            return
        }
        
        promotionService.showModal(on: vc, id: id) { result in
            print("Handle if needed, result: \(result)")
        }
    }
    
}

// MARK: - UITabBarControllerDelegate
extension MainTabCoordinator: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if currentNavigationController == tabNavigationControllers[tabBarController.selectedIndex] {
            return
        }
        currentNavigationController?.dismiss(animated: true)
        currentNavigationController?.popToRootViewController(animated: false)
        currentNavigationController = tabNavigationControllers[tabBarController.selectedIndex]
    }
}
