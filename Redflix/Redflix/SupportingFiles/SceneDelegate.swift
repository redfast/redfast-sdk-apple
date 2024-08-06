//
//  SceneDelegate.swift
//  Redflix
//
//  Created by Volodymyr Mykhailiuk on 03.05.2024.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
#if os(iOS)
    private(set) var appCoordinator: AppCoordinator?
#endif
    
    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
#if os(iOS)
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        self.window = window
        
        appCoordinator = AppCoordinator(window: window)
        appCoordinator?.start()
        
        let notificationService: NotificationServiceProtocol = ServiceLocator.shared.resolve()
        
        if let userInfo = connectionOptions.notificationResponse?.notification.request.content.userInfo, let result = userInfo["data"] {
            if let payload = notificationService.notificationPayload(from: result) {
                appCoordinator?.handleDeepLink(payload.pinpoint.deeplink)
            }
        }
#endif
    }
}
