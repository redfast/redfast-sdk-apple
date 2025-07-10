//
//  NotificationService.swift
//  Redflix
//
//  Created by Volodymyr Mykhailiuk on 04.06.2024.
//

import Foundation
import UIKit

protocol NotificationServiceProtocol {
    func grantAccess(_ completion: ((UNAuthorizationStatus) -> Void)?)
    func registerNotification()
    func notificationPayload(from userInfo: Any) -> NotificationPayload?
}

final class NotificationService: NotificationServiceProtocol {
    private let decoder = JSONDecoder()

    func grantAccess(_ completion: ((UNAuthorizationStatus) -> Void)?) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.badge, .sound, .alert, .providesAppNotificationSettings]) { registered, _ in
            guard registered else {
                completion?(.notDetermined)
                return
            }

            UNUserNotificationCenter.current().getNotificationSettings {
                completion?($0.authorizationStatus)
            }
        }
    }

    func registerNotification() {
        DispatchQueue.main.async {
            UIApplication.shared.registerForRemoteNotifications()
        }
    }

    func notificationPayload(from userInfo: Any) -> NotificationPayload? {
        do {
            let data = try JSONSerialization.data(withJSONObject: userInfo)
            let payload = try JSONDecoder().decode(NotificationPayload.self, from: data)
            return payload
        } catch {
            print("Can not decode notification payload: \(error.localizedDescription)")
            return nil
        }
    }
}
