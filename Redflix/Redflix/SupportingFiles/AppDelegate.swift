//
//  AppDelegate.swift
//  Redflix
//
//  Created by Volodymyr Mykhailiuk on 03.05.2024.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
#if os(tvOS)
    var window: UIWindow?
    private var appCoordinator: AppCoordinator?
#elseif os(iOS)
    var appCoordinator: AppCoordinator? {
        guard let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate else {
            return nil
        }
        return sceneDelegate.appCoordinator
    }
#endif
    
    private let services = ServiceLocator.shared
    private var notificationService: NotificationServiceProtocol!
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        registerServices()
        registerFonts()
        registerNotifications()
        
#if os(tvOS)
        let window = UIWindow(frame: UIScreen.main.bounds)
        self.window = window
        appCoordinator = AppCoordinator(window: window)
        appCoordinator?.start()
#endif
        
        return true
    }
    
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        let tokenParts = deviceToken.map { data in
            String(format: "%02.2hhx", data)
        }
        let token = tokenParts.joined()
        print(token)
        appCoordinator?.registerToken(token)
    }
    
    private func registerFonts() {
        CustomFontType.allCases.forEach {
            UIFont.registerFont(withFilenameString: $0.rawValue, bundle: Bundle(for: AppDelegate.self))
        }
    }
    
    private func registerServices() {
        services.register(service: RedflixAPI(networkManager: NetworkManager()) as RedflixAPIProtocol)
        services.register(service: ImageLoader() as ImageLoaderProtocol)
        services.register(service: DateFormatterService() as DateFormatting)
        services.register(service: EmailValidator() as EmailValidatorProtocol)
        services.register(service: PromotionService() as PromotionServiceProtocol)
        services.register(service: SDKStatusManager() as SDKStatusManaging)
        self.notificationService = NotificationService()
        services.register(service: self.notificationService as NotificationServiceProtocol)
        services.register(service: DeepLinkService() as DeepLinkServiceProtocol)
        services.register(service: PurchaseManager() as PurchaseManagerProtocol)
        services.register(service: UserDefaultsService() as UserDefaultsServiceProtocol)
    }
    
    private func registerNotifications() {
        notificationService.grantAccess { [weak self] status in
            guard let self else { return }
            guard status == .authorized else {
                return
            }
            UNUserNotificationCenter.current().delegate = self
            notificationService.registerNotification()
        }
    }
}

// MARK: - UNUserNotificationCenterDelegate
extension AppDelegate: UNUserNotificationCenterDelegate {
#if os(iOS)
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        guard let result = response.notification.request.content.userInfo["data"] else {
            completionHandler()
            return
        }
        if let payload = notificationService.notificationPayload(from: result) {
            appCoordinator?.handleDeepLink(payload.pinpoint.deeplink)
        }
        completionHandler()
    }
#endif
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound, .badge, .list])
    }
}
