//
//  MockPromotionView.swift
//  RedflixTests
//
//  Created by Volodymyr Mykhailiuk on 31.05.2024.
//

import Foundation
@testable import Redflix

final class MockPromotionView: PromotionViewProtocol {
    var screenName = ""
    
    var name: String {
        screenName
    }
}
