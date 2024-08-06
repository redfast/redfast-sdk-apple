//
//  NotificationPayload.swift
//  Redflix
//
//  Created by Volodymyr Mykhailiuk on 06.06.2024.
//

import Foundation

struct NotificationPayload: Decodable {
    let pinpoint: Pinpoint

    struct Pinpoint: Codable {
        let deeplink: URL
    }
}
