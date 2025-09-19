//
//  AppDelegate.swift
//  Redflix
//
//  Created by Volodymyr Mykhailiuk on 03.05.2024.
//

import UIKit
import Combine
import RedFast

// MARK: - Notification Payload Storage
class NotificationPayloadStore: ObservableObject {
    static let shared = NotificationPayloadStore()
    private init() {}

    @Published var latestPayload: [AnyHashable: Any]?

    func updatePayload(_ payload: [AnyHashable: Any]) {
        latestPayload = payload
    }

    func getPayloadString() -> String {
        guard let payload = latestPayload else {
            return "No push notifications received yet"
        }

        do {
            let jsonData = try JSONSerialization.data(withJSONObject: payload, options: .prettyPrinted)
            return String(data: jsonData, encoding: .utf8) ?? "Failed to format payload"
        } catch {
            return "Payload: \(payload)"
        }
    }
}

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

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        registerServices()
        registerFonts()
        UNUserNotificationCenter.current().delegate = self
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
        print("APPDELEGATE: ✅ didRegisterForRemoteNotificationsWithDeviceToken")
    }

    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        print("APPDELEGATE:❌ didRegisterForRemoteNotificationsWithDeviceToken in the APP")
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
        services.register(service: DeepLinkService() as DeepLinkServiceProtocol)
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
        // Store the payload for profile screen display
        NotificationPayloadStore.shared.updatePayload(response.notification.request.content.userInfo)
        completionHandler()
    }


    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound, .badge, .list])
    }


#endif
}
