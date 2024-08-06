//
//  UIFont+Register.swift
//  Redflix
//
//  Created by Volodymyr Mykhailiuk on 13.05.2024.
//

import UIKit

extension UIFont {
    static func registerFont(withFilenameString filenameString: String, bundle: Bundle) {
        guard let fontURL = bundle.url(forResource: filenameString, withExtension: "ttf") else {
            print("UIFont+:  Failed to register font - path for resource not found.")
            return
        }
        guard let dataProvider = CGDataProvider(url: fontURL as CFURL) else {
            print("UIFont+:  Failed to register font - data provider could not be loaded.")
            return
        }
        guard let font = CGFont(dataProvider) else {
            print("UIFont+:  Failed to register font - font could not be loaded.")
            return
        }
        var errorRef: Unmanaged<CFError>? = nil
        if (CTFontManagerRegisterGraphicsFont(font, &errorRef) == false) {
            print("UIFont+:  Failed to register font - register graphics font failed - this font may have already been registered in the main bundle.")
        }
    }
}
