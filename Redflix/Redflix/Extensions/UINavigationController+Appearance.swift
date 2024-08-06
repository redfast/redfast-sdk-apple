//
//  UINavigationController+Appearance.swift
//  Redflix
//
//  Created by Volodymyr Mykhailiuk on 20.05.2024.
//

import UIKit

extension UINavigationController {
    func setupBrandAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = AppColor.navBarColor
        self.navigationBar.standardAppearance = appearance
        self.navigationBar.scrollEdgeAppearance = self.navigationBar.standardAppearance
        
        self.navigationBar.tintColor = .white
        self.navigationBar.isTranslucent = false
    }
}
