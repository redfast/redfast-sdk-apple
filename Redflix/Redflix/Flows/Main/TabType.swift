//
//  TabType.swift
//  Redflix
//
//  Created by Volodymyr Mykhailiuk on 03.05.2024.
//

import Foundation

enum TabType: String {
    case home
    case latest
    case genres
    case profile

    init?(index: Int) {
        switch index {
        case 0:
            self = .home
        case 1:
            self = .latest
        case 2:
            self = .genres
        case 3:
            self = .profile
        default:
            return nil
        }
    }
    
    var titleValue: String {
        self.rawValue.capitalized
    }
    
    var iconName: String {
        switch self {
        case .home:
            return "homeTabIcon"
        case .latest:
            return "latestTabIcon"
        case .genres:
            return "genresTabIcon"
        case .profile:
            return "profileTabIcon"
        }
    }

    var index: Int {
        switch self {
        case .home:
            return 0
        case .latest:
            return 1
        case .genres:
            return 2
        case .profile:
            return 3
        }
    }
}
