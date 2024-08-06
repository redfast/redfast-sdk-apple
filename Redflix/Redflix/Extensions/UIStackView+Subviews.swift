//
//  UIStackView+Subviews.swift
//  Redflix
//
//  Created by Volodymyr Mykhailiuk on 17.05.2024.
//

import UIKit

extension UIStackView {
    func addArrangedSubviews(_ views: [UIView]) {
        views.forEach {
            addArrangedSubview($0)
        }
    }
}
