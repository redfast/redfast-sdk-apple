//
//  RedflixApp.swift
//  Redflix
//
//  Created by Wenwei Tao on 12/11/25.
//

import SwiftUI
import Combine
import redfast_ui
import redfast_core
// import redfast_ui_push   // Step 1: add the redfast-ui-push product to your target

@main
struct RedflixApp: App {

    // Step 2: attach the AppDelegate so push callbacks are forwarded to the SDK.
    // @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    @StateObject private var redfastStatus: RedfastStatus = .init()

    var body: some Scene {
        WindowGroup {
            RedflixTabBar()
                .environmentObject(redfastStatus)
        }
    }
}


class RedfastStatus: ObservableObject {
    @Published var isInitialized: Bool = false

    init() {
        initializeRedfast()
    }

    private func initializeRedfast() {
        PromptManager.initPrompt(appId: AppConstants.appId, userId: AppConstants.userId) { result in
            guard result.code == .OK else {
                return
            }
            self.isInitialized = true
        }
    }
}


// MARK: - Push notification integration example
//
// Uncomment this AppDelegate and the @UIApplicationDelegateAdaptor above to
// enable push notifications. RedfastPushManager handles swizzling automatically
// so no other changes are needed in your delegate.
//
// class AppDelegate: NSObject, UIApplicationDelegate {
//
//     func application(
//         _ application: UIApplication,
//         didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
//     ) -> Bool {
//         // Optional — configure Firebase before the push manager if using FCM:
//         // FirebaseApp.configure()
//
//         // Step 3: configure the push manager after PromptManager is initialized.
//         // RedfastPushManager requests permissions, registers for remote
//         // notifications, and proxies UNUserNotificationCenter automatically.
//         RedfastPushManager.shared.configure()
//         return true
//     }
// }
