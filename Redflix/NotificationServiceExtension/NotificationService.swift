//
//  NotificationService.swift
//  NotificationServiceExtension
//
//  Created by GitHub Copilot on 07.07.2025!!
//

import UserNotifications

class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)

        // Debug logging for physical device testing
        print("🔔 NotificationService: Extension was invoked!")
        print("🔔 UserInfo: \(request.content.userInfo)")
        print("🔔 Notification identifier: \(request.identifier)")

        // Check if notification is configured for modification
        if let aps = request.content.userInfo["aps"] as? [String: Any] {
            print("🔍 NotificationService: APS payload: \(aps)")
            if let mutableContent = aps["mutable-content"] as? Int, mutableContent == 1 {
                print("✅ NotificationService: mutable-content is set to 1")
            } else {
                print("⚠️ NotificationService: mutable-content is not set or not 1")
            }
        }

        guard let bestAttemptContent = bestAttemptContent else {
            print("❌ NotificationService: Failed to create mutable content")
            contentHandler(request.content)
            return
        }

        // Set up notification actions based on payload
        setupNotificationActions(for: bestAttemptContent, from: request.content.userInfo)

        // Add visible indicator that extension is running (temporary debug)
        bestAttemptContent.title = "🔧 " + bestAttemptContent.title

        // Use the real payload instead of hardcoded test URL
        if let imageURLString = getImageURL(from: request.content.userInfo),
           let imageURL = URL(string: imageURLString) {
            print("✅ NotificationService: Found image URL in payload: \(imageURLString)")
            downloadAndAttachImage(from: imageURL, to: bestAttemptContent, completion: contentHandler)
        } else {
            print("⚠️ NotificationService: No media-url found in payload")
            // Still call completion so notification shows
            print("🔚 NotificationService: Calling completion handler (no image URL)")
            contentHandler(bestAttemptContent)
        }
    }

    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content,
        // otherwise the original push payload will be used.
        print("⏰ NotificationService: serviceExtensionTimeWillExpire called - running out of time!")
        if let contentHandler = contentHandler, let bestAttemptContent = bestAttemptContent {
            print("⏰ NotificationService: Delivering best attempt content with \(bestAttemptContent.attachments.count) attachments")
            contentHandler(bestAttemptContent)
        }
    }


    private func getImageURL(from userInfo: [AnyHashable: Any]) -> String? {
        print("🔍 NotificationService: Searching for image URL in payload")
        print("🔍 NotificationService: Available keys: \(Array(userInfo.keys))")

        // Amazon Pinpoint typically nests media-url in the data object (most common)
        if let customData = userInfo["data"] as? [String: Any],
           let imageURL = customData["media-url"] as? String {
            print("✅ NotificationService: Found media-url in data: \(imageURL)")
            return imageURL
        }

        // Check for media-url at root level (fallback)
        if let imageURL = userInfo["media-url"] as? String {
            print("✅ NotificationService: Found media-url at root: \(imageURL)")
            return imageURL
        }

        // Try other common image URL keys
        if let imageURL = userInfo["image"] as? String {
            print("✅ NotificationService: Found image at root: \(imageURL)")
            return imageURL
        }

        if let customData = userInfo["data"] as? [String: Any],
           let imageURL = customData["media-url"] as? String {
            print("✅ NotificationService: Found image in data: \(imageURL)")
            return imageURL
        }

        // Check nested pinpoint structures
        if let customData = userInfo["data"] as? [String: Any],
           let pinpoint = customData["pinpoint"] as? [String: Any],
           let imageURL = pinpoint["media-url"] as? String {
            print("✅ NotificationService: Found media-url in data.pinpoint: \(imageURL)")
            return imageURL
        }

        if let pinpoint = userInfo["pinpoint"] as? [String: Any],
           let imageURL = pinpoint["imageUrl"] as? String {
            print("✅ NotificationService: Found imageUrl in pinpoint: \(imageURL)")
            return imageURL
        }

        if let pinpoint = userInfo["pinpoint"] as? [String: Any],
           let imageURL = pinpoint["media-url"] as? String {
            print("✅ NotificationService: Found media-url in pinpoint: \(imageURL)")
            return imageURL
        }

        // Check for media attachment in the aps payload
        if let aps = userInfo["aps"] as? [String: Any],
           let alert = aps["alert"] as? [String: Any],
           let imageURL = alert["attachment-url"] as? String {
            print("✅ NotificationService: Found attachment-url in aps.alert: \(imageURL)")
            return imageURL
        }

        // Check for common Amazon Pinpoint fields
        if let fcmOptions = userInfo["fcm_options"] as? [String: Any],
           let imageURL = fcmOptions["image"] as? String {
            print("✅ NotificationService: Found image in fcm_options: \(imageURL)")
            return imageURL
        }

        print("❌ NotificationService: No image URL found in payload")
        return nil
    }

    private func downloadAndAttachImage(from url: URL, to content: UNMutableNotificationContent, completion: @escaping (UNNotificationContent) -> Void) {
        print("📥 NotificationService: Starting image download from: \(url)")

        // Create a custom URLSession with shorter timeout to ensure we complete within iOS limits
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 15.0 // Reduced from 25 to 15 seconds
        config.timeoutIntervalForResource = 15.0
        let session = URLSession(configuration: config)

        let startTime = Date()

        session.dataTask(with: url) { data, response, error in
            let downloadTime = Date().timeIntervalSince(startTime)
            print("⏱️ NotificationService: Download took \(String(format: "%.2f", downloadTime)) seconds")

            // Don't use defer - we want to control exactly when completion is called

            if let error = error {
                print("❌ NotificationService: Image download failed: \(error.localizedDescription)")
                print("❌ NotificationService: Error code: \((error as NSError).code)")
                print("❌ NotificationService: Error domain: \((error as NSError).domain)")
                print("🔚 NotificationService: Calling completion handler (download error)")
                completion(content)
                return
            }

            guard let data = data else {
                print("❌ NotificationService: No image data received")
                print("🔚 NotificationService: Calling completion handler (no data)")
                completion(content)
                return
            }

            guard data.count > 0 else {
                print("❌ NotificationService: Empty image data received")
                print("🔚 NotificationService: Calling completion handler (empty data)")
                completion(content)
                return
            }

            print("✅ NotificationService: Image downloaded successfully, size: \(data.count) bytes")

            // Validate response first
            if let httpResponse = response as? HTTPURLResponse {
                print("📊 NotificationService: HTTP Status: \(httpResponse.statusCode)")
                print("📊 NotificationService: Content-Type: \(httpResponse.allHeaderFields["Content-Type"] ?? "unknown")")

                // Accept all 2xx status codes (200-299) as successful
                if !(200...299).contains(httpResponse.statusCode) {
                    print("❌ NotificationService: HTTP error - status code: \(httpResponse.statusCode)")
                    print("🔚 NotificationService: Calling completion handler (HTTP error)")
                    completion(content)
                    return
                }
            }

            // Validate that we have some data
            guard self.isValidImageData(data) else {
                print("❌ NotificationService: Downloaded data is not a valid image")
                print("🔚 NotificationService: Calling completion handler (invalid data)")
                completion(content)
                return
            }

            guard let attachment = self.createImageAttachment(from: data, url: url) else {
                print("❌ NotificationService: Failed to create image attachment")
                print("🔚 NotificationService: Calling completion handler (attachment failed)")
                completion(content)
                return
            }

            print("✅ NotificationService: Image attachment created successfully")
            content.attachments = [attachment]
            print("✅ NotificationService: Attachment added to content. Total attachments: \(content.attachments.count)")

            // Confirm the attachment details
            if let firstAttachment = content.attachments.first {
                print("📎 NotificationService: Attachment identifier: \(firstAttachment.identifier)")
                print("📎 NotificationService: Attachment URL: \(firstAttachment.url)")
                print("📎 NotificationService: Attachment type: \(firstAttachment.type)")
            }

            // NOW we call completion - after everything is ready
            print("🔚 NotificationService: Calling completion handler (SUCCESS with image)")
            completion(content)
        }.resume()
    }

    private func createImageAttachment(from data: Data, url: URL) -> UNNotificationAttachment? {
        let fileManager = FileManager.default
        let tempDirectory = fileManager.temporaryDirectory

        // Use a simple filename - iOS will detect the image type automatically
        let fileName = "notification_image.jpg"
        let fileURL = tempDirectory.appendingPathComponent(fileName)

        print("📁 NotificationService: Creating attachment at: \(fileURL)")
        print("📁 NotificationService: Data size: \(data.count) bytes")

        do {
            // Remove existing file if it exists
            if fileManager.fileExists(atPath: fileURL.path) {
                try fileManager.removeItem(at: fileURL)
            }

            // Write the image data
            try data.write(to: fileURL)
            print("✅ NotificationService: Image file written successfully")

            // Create attachment - let iOS figure out the image type
            let attachment = try UNNotificationAttachment(
                identifier: "image-\(Date().timeIntervalSince1970)",
                url: fileURL,
                options: nil  // No options needed - iOS will auto-detect
            )

            print("✅ NotificationService: UNNotificationAttachment created successfully")
            return attachment

        } catch {
            print("❌ NotificationService: Failed to create attachment: \(error.localizedDescription)")
            return nil
        }
    }

    private func isValidImageData(_ data: Data) -> Bool {
        // Check minimum size
        guard data.count > 100 else {
            print("❌ NotificationService: Image data too small: \(data.count) bytes")
            return false
        }

        // Check maximum size (iOS limit is ~10MB, but let's be conservative)
        let maxSize = 5 * 1024 * 1024 // 5MB
        guard data.count <= maxSize else {
            print("❌ NotificationService: Image data too large: \(data.count) bytes (max: \(maxSize))")
            return false
        }

        print("✅ NotificationService: Image data size is acceptable: \(data.count) bytes")
        return true
    }

    private func setupNotificationActions(for content: UNMutableNotificationContent, from userInfo: [AnyHashable: Any]) {
        print("🔘 NotificationService: Setting up notification actions")

        // Look for actions in the payload
        var actions: [UNNotificationAction] = []

        // Check for actions in data.actions array
        if let customData = userInfo["data"] as? [String: Any],
           let actionsData = customData["actions"] as? [[String: Any]] {
            print("✅ NotificationService: Found actions in data.actions")
            actions = createActionsFromPayload(actionsData)
        }
        // Check for actions at root level
        else if let actionsData = userInfo["actions"] as? [[String: Any]] {
            print("✅ NotificationService: Found actions at root level")
            actions = createActionsFromPayload(actionsData)
        }
        // Check for pinpoint actions
        else if let customData = userInfo["data"] as? [String: Any],
                let pinpoint = customData["pinpoint"] as? [String: Any],
                let actionsData = pinpoint["actions"] as? [[String: Any]] {
            print("✅ NotificationService: Found actions in data.pinpoint.actions")
            actions = createActionsFromPayload(actionsData)
        }

        if !actions.isEmpty {
            // Create unique category identifier
            let categoryId = "REDFLIX_ACTIONS_\(Date().timeIntervalSince1970)"
            print("📋 NotificationService: Creating category \(categoryId) with \(actions.count) actions")

            // Create category with actions
            let category = UNNotificationCategory(
                identifier: categoryId,
                actions: actions,
                intentIdentifiers: [],
                options: [.customDismissAction]
            )

            // Register the category
            UNUserNotificationCenter.current().setNotificationCategories([category])

            // Set the category on the content
            content.categoryIdentifier = categoryId

            print("✅ NotificationService: Notification category set with \(actions.count) actions")
        } else {
            print("ℹ️ NotificationService: No actions found in payload")
        }
    }

    private func createActionsFromPayload(_ actionsData: [[String: Any]]) -> [UNNotificationAction] {
        var actions: [UNNotificationAction] = []

        for (index, actionData) in actionsData.enumerated() {
            guard let title = actionData["title"] as? String else {
                print("⚠️ NotificationService: Action at index \(index) missing title")
                continue
            }

            let actionId = actionData["id"] as? String ?? "action_\(index)"
            let destructive = actionData["destructive"] as? Bool ?? false
            let authRequired = actionData["authRequired"] as? Bool ?? false
            let foreground = actionData["foreground"] as? Bool ?? false

            // Create action options
            var options: UNNotificationActionOptions = []
            if destructive {
                options.insert(.destructive)
            }
            if authRequired {
                options.insert(.authenticationRequired)
            }
            if foreground {
                options.insert(.foreground)
            }

            let action = UNNotificationAction(
                identifier: actionId,
                title: title,
                options: options
            )

            actions.append(action)

            print("🔘 NotificationService: Created action '\(title)' with ID '\(actionId)'")
            if let deeplink = actionData["deeplink"] as? String {
                print("🔗 NotificationService: Action deeplink: \(deeplink)")
            }
        }

        return actions
    }
}
