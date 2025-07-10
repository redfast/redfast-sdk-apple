//
//  AppDelegate.swift
//  Redflix
//
//  Created by Volodymyr Mykhailiuk on 03.05.2024.
//

import UIKit
import Combine

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
    private var notificationService: NotificationServiceProtocol!

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        print("APPDELEGATE: didFinishLaunchingWithOptions called")
        registerServices()
        registerFonts()
        registerNotifications()

#if os(tvOS)
        let window = UIWindow(frame: UIScreen.main.bounds)
        self.window = window
        appCoordinator = AppCoordinator(window: window)
        appCoordinator?.start()
#endif

        print("APPDELEGATE: Setup complete")
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
        print("📱✅ Device token registered successfully:")
        print("📱✅ Token: \(token)")
        appCoordinator?.registerToken(token)
    }

    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        print("📱❌ Failed to register for remote notifications:")
        print("📱❌ Error: \(error.localizedDescription)")
        print("📱❌ Full error: \(error)")
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
        print("APPDELEGATE: Starting notification registration")
        notificationService.grantAccess { [weak self] status in
            print("APPDELEGATE: Notification permission status: \(status)")
            guard let self else { return }
            guard status == .authorized else {
                print("APPDELEGATE: Notifications not authorized")
                return
            }
            print("APPDELEGATE: Notifications authorized, setting delegate")
            UNUserNotificationCenter.current().delegate = self
            notificationService.registerNotification()

            // Verify delegate is set
            DispatchQueue.main.async {
                let currentDelegate = UNUserNotificationCenter.current().delegate
                print("APPDELEGATE: Delegate set successfully: \(currentDelegate != nil)")
            }
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
        print("🚨 didReceive delegate method called!")
        print("🔘 Action identifier: \(response.actionIdentifier)")

        // Store the payload for profile screen display
        NotificationPayloadStore.shared.updatePayload(response.notification.request.content.userInfo)

        // Debug log: Print the complete notification payload
        print("🔔📱 Push notification received (user tapped):")
        print("🔔📱 Complete payload: \(response.notification.request.content.userInfo)")

        // Check for media-url specifically
        if let mediaUrl = response.notification.request.content.userInfo["media-url"] as? String {
            print("🔔📱 Found media-url: \(mediaUrl)")
        }

        // Check for other image fields
        if let data = response.notification.request.content.userInfo["data"] as? [String: Any],
           let imageUrl = data["image"] as? String {
            print("🔔📱 Found image in data: \(imageUrl)")
        }

        // Handle notification actions
        handleNotificationAction(response: response)

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
        print("🚨 willPresent delegate method called!")

        // Store the payload for profile screen display
        NotificationPayloadStore.shared.updatePayload(notification.request.content.userInfo)

        // Debug log: Print the complete notification payload when received while app is active
        print("🔔📱 Push notification received (app in foreground):")
        print("🔔📱 Complete payload: \(notification.request.content.userInfo)")

        // Check for media-url specifically
        if let mediaUrl = notification.request.content.userInfo["media-url"] as? String {
            print("🔔📱 Found media-url: \(mediaUrl)")
        }

        // Check for mutable-content flag
        if let aps = notification.request.content.userInfo["aps"] as? [String: Any],
           let mutableContent = aps["mutable-content"] as? Int {
            print("🔔📱 Mutable content flag: \(mutableContent)")
        }

        completionHandler([.banner, .sound, .badge, .list])
    }

    private func handleNotificationAction(response: UNNotificationResponse) {
        let actionIdentifier = response.actionIdentifier
        let userInfo = response.notification.request.content.userInfo

        print("🔘 Handling notification action: \(actionIdentifier)")

        // Handle default action (notification tap)
        if actionIdentifier == UNNotificationDefaultActionIdentifier {
            print("🔘 User tapped notification (default action)")
            return
        }

        // Handle dismiss action
        if actionIdentifier == UNNotificationDismissActionIdentifier {
            print("🔘 User dismissed notification")
            return
        }

        // Handle custom actions
        var actionData: [String: Any]?

        // Look for actions in the payload to find the deeplink
        if let customData = userInfo["data"] as? [String: Any],
           let actionsArray = customData["actions"] as? [[String: Any]] {
            actionData = actionsArray.first { ($0["id"] as? String) == actionIdentifier }
        } else if let actionsArray = userInfo["actions"] as? [[String: Any]] {
            actionData = actionsArray.first { ($0["id"] as? String) == actionIdentifier }
        } else if let customData = userInfo["data"] as? [String: Any],
                  let pinpoint = customData["pinpoint"] as? [String: Any],
                  let actionsArray = pinpoint["actions"] as? [[String: Any]] {
            actionData = actionsArray.first { ($0["id"] as? String) == actionIdentifier }
        }

        if let actionData = actionData {
            let title = actionData["title"] as? String ?? "Unknown Action"
            print("🔘 Executing action: \(title)")

            if let deeplink = actionData["deeplink"] as? String {
                print("🔗 Action deeplink: \(deeplink)")

                // Handle the deeplink through the app coordinator
                DispatchQueue.main.async {
                    if let url = URL(string: deeplink) {
                        self.appCoordinator?.handleDeepLink(url)
                    } else {
                        print("⚠️ Invalid deeplink URL: \(deeplink)")
                    }
                }
            } else {
                print("⚠️ No deeplink found for action \(actionIdentifier)")
            }
        } else {
            print("⚠️ No action data found for identifier: \(actionIdentifier)")
        }
    }
}
