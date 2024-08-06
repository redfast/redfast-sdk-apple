//
//  UIEdgeInsets+Init.swift
//  Redflix
//
//  Created by Volodymyr Mykhailiuk on 14.05.2024.
//

import UIKit

extension UIEdgeInsets {
    init(all: CGFloat) {
        self.init(horizontal: all, vertical: all)
    }
    
    init(horizontal: CGFloat, vertical: CGFloat) {
        self.init(
            top: vertical,
            left: horizontal,
            bottom: vertical,
            right: horizontal
        )
    }
}
