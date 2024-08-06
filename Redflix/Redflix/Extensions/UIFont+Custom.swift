//
//  UIFont+Custom.swift
//  Redflix
//
//  Created by Volodymyr Mykhailiuk on 09.05.2024.
//

import UIKit

enum CustomFontType: String, CaseIterable {
    case catamaranExtraBold = "Catamaran-ExtraBold"
    case catamaranBold = "Catamaran-Bold"
    case catamaranMedium = "Catamaran-Medium"
    case catamaranRegular = "Catamaran-Regular"
    case robotoRegular = "Roboto-Regular"
    case robotoLight = "Roboto-Light"
    case robotoMedium = "Roboto-Medium"
    case robotoBold = "Roboto-Bold"
}

extension UIFont {
    static func custom(type: CustomFontType, ofSize size: CGFloat) -> UIFont {
        guard let font = UIFont(name: type.rawValue, size: size) else {
            preconditionFailure("Make sure you added font")
        }
        return font
    }
}
