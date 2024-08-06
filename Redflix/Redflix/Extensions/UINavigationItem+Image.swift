//
//  UINavigationItem+Image.swift
//  Redflix
//
//  Created by Volodymyr Mykhailiuk on 14.05.2024.
//

import UIKit

extension UINavigationItem {
    func applyBrandNavigationTitle() {
#if os(iOS)
        let imageView = UIImageView(image: UIImage(named: "redflixLogo"))
        imageView.contentMode = .scaleAspectFit
        self.titleView = imageView
#endif
    }
}
