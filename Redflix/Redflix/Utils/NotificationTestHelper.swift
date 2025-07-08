//
//  NotificationTestHelper.swift
//  Redflix
//
//  Created by GitHub Copilot on 07.07.2025.
//

import UserNotifications
import UIKit

class NotificationTestHelper {

    static func testRichNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Test Rich Notification"
        content.body = "This is a test notification with the default image"
        content.sound = .default

        // Test with default image URL
        content.userInfo = [
            "media-url": "https://REMOVED.redfastlabs.com/assets/b1f950a1-1a30-4fcc-b6c4-cffb51b45271_rf_pinpoint_ios_image_1751929324.jpeg"
        ]

        // This is crucial - tells iOS that this notification can be modified
        content.setValue(1, forKey: "mutable-content")

        let request = UNNotificationRequest(
            identifier: "test-rich-notification",
            content: content,
            trigger: UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Failed to schedule test notification: \(error)")
            } else {
                print("✅ Test notification scheduled - should appear in 5 seconds with default image")
            }
        }
    }

    static func testAmazonPinpointStyleNotification() {
        let content = UNMutableNotificationContent()
        content.title = "test7"
        content.body = "test7"

        // Use the exact Amazon Pinpoint payload structure from your sample
        content.userInfo = [
            "data": [
                "media-url": "https://media.istockphoto.com/id/482400606/photo/just-chillin.png?s=1024x1024&w=is&k=20&c=mbpp4C6OO6r2_S0A8hbsLx52BcpgiDVWIVmUIJBB0gQ=",
                "pinpoint": [
                    "deeplink": "https://www.redfast.com"
                ]
            ],
            "aps": [
                "mutable-content": 1,
                "alert": [
                    "title": "test7",
                    "body": "test7"
                ],
                "content-available": 1
            ]
        ]

        // This is crucial - tells iOS that this notification can be modified
        content.setValue(1, forKey: "mutable-content")

        let request = UNNotificationRequest(
            identifier: "test-amazon-pinpoint-notification",
            content: content,
            trigger: UNTimeIntervalNotificationTrigger(timeInterval: 3, repeats: false)
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Failed to schedule Amazon Pinpoint test notification: \(error)")
            } else {
                print("✅ Amazon Pinpoint test notification scheduled - should appear in 3 seconds with image")
            }
        }
    }

    static func requestNotificationPermissions() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("✅ Notification permissions granted")
            } else {
                print("❌ Notification permissions denied: \(error?.localizedDescription ?? "unknown")")
            }
        }
    }

    static func enableDebugMode() {
        // Enable debug logging for notification testing
        print("🔧 NotificationTestHelper: Debug mode enabled")

        // Test device token display
        if let deviceToken = UserDefaults.standard.string(forKey: "deviceToken") {
            print("📱 Current device token: \(deviceToken)")
        } else {
            print("❌ No device token found")
        }

        // Test notification permissions
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            print("🔔 Notification authorization status: \(settings.authorizationStatus.rawValue)")
            print("🔔 Alert setting: \(settings.alertSetting.rawValue)")
            print("🔔 Sound setting: \(settings.soundSetting.rawValue)")
            print("🔔 Badge setting: \(settings.badgeSetting.rawValue)")
        }
    }

    static func testAllNotificationTypes() {
        print("🧪 Testing all notification types...")

        requestNotificationPermissions()

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            testRichNotification()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 7) {
            testAmazonPinpointStyleNotification()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 12) {
            testNotificationWithoutMediaURL()
        }
    }

    static func analyzeNotificationPayload(_ userInfo: [AnyHashable: Any]) {
        print("🔍 Analyzing notification payload structure:")
        print("🔍 Root keys: \(Array(userInfo.keys))")

        // Check for media-url at root level
        if let mediaUrl = userInfo["media-url"] {
            print("✅ Found 'media-url' at root: \(mediaUrl)")
        }

        // Check aps structure
        if let aps = userInfo["aps"] as? [String: Any] {
            print("🔍 APS keys: \(Array(aps.keys))")
            if let mutableContent = aps["mutable-content"] {
                print("✅ Found 'mutable-content': \(mutableContent)")
            }
            if let alert = aps["alert"] {
                print("🔍 Alert content: \(alert)")
            }
        }

        // Check data structure
        if let data = userInfo["data"] as? [String: Any] {
            print("🔍 Data keys: \(Array(data.keys))")
            if let imageUrl = data["image"] {
                print("✅ Found 'image' in data: \(imageUrl)")
            }
            if let mediaUrl = data["media-url"] {
                print("✅ Found 'media-url' in data: \(mediaUrl)")
            }
        }

        // Check pinpoint structure
        if let pinpoint = userInfo["pinpoint"] as? [String: Any] {
            print("🔍 Pinpoint keys: \(Array(pinpoint.keys))")
        }
    }

    static func simulateNotificationPayload() {
        // Simulate the exact Amazon Pinpoint notification payload structure
        let testPayload: [AnyHashable: Any] = [
            "data": [
                "media-url": "https://media.istockphoto.com/id/482400606/photo/just-chillin.png?s=1024x1024&w=is&k=20&c=mbpp4C6OO6r2_S0A8hbsLx52BcpgiDVWIVmUIJBB0gQ=",
                "pinpoint": [
                    "deeplink": "https://www.redfast.com"
                ]
            ],
            "aps": [
                "mutable-content": 1,
                "alert": [
                    "title": "test7",
                    "body": "test7"
                ],
                "content-available": 1
            ],
            "timestamp": ISO8601DateFormatter().string(from: Date())
        ]

        // Store the test payload
        NotificationPayloadStore.shared.updatePayload(testPayload)
        print("🧪 Simulated Amazon Pinpoint notification payload updated in profile screen")
    }

    static func testNotificationWithoutMediaURL() {
        let content = UNMutableNotificationContent()
        content.title = "Test Notification - No Media URL"
        content.body = "This notification has no media-url and should use the default image"
        content.sound = .default

        // No media-url provided - should use default image
        content.userInfo = [
            "aps": [
                "alert": [
                    "title": "Test Notification - No Media URL",
                    "body": "This notification has no media-url and should use the default image"
                ],
                "mutable-content": 1,
                "content-available": 1
            ],
            "data": [
                "some_field": "some_value"
            ]
        ]

        // This is crucial - tells iOS that this notification can be modified
        content.setValue(1, forKey: "mutable-content")

        let request = UNNotificationRequest(
            identifier: "test-no-media-url-notification",
            content: content,
            trigger: UNTimeIntervalNotificationTrigger(timeInterval: 7, repeats: false)
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Failed to schedule no-media-url test notification: \(error)")
            } else {
                print("✅ No-media-url test notification scheduled - should appear in 7 seconds with default image")
            }
        }
    }

    static func testSimulatorNotifications() {
        print("🧪 Testing notifications for simulator...")

        // Test 1: With media-url
        testAmazonPinpointStyleNotification()

        // Test 2: Without media-url (should use default image)
        DispatchQueue.main.asyncAfter(deadline: .now() + 8) {
            testNotificationWithoutMediaURL()
        }

        // Test 3: Simple notification
        DispatchQueue.main.asyncAfter(deadline: .now() + 16) {
            let content = UNMutableNotificationContent()
            content.title = "Simple Test"
            content.body = "Basic notification without rich media"
            content.sound = .default
            content.badge = 1

            let request = UNNotificationRequest(
                identifier: "simple-test",
                content: content,
                trigger: UNTimeIntervalNotificationTrigger(timeInterval: 2, repeats: false)
            )

            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("❌ Failed to schedule simple test: \(error)")
                } else {
                    print("✅ Simple test notification scheduled")
                }
            }
        }
    }
}
