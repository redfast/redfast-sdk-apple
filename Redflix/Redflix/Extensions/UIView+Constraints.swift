//
//  UIView+Constraints.swift
//  Redflix
//
//  Created by Volodymyr Mykhailiuk on 07.05.2024.
//

import UIKit

extension UIView {
    struct AnchorConstraints {
        var top: CGFloat?
        var bottom: CGFloat?
        var leading: CGFloat?
        var trailing: CGFloat?
        var width: CGFloat?
        var height: CGFloat?

        init(
            top: CGFloat? = nil,
            bottom: CGFloat? = nil,
            leading: CGFloat? = nil,
            trailing: CGFloat? = nil,
            width: CGFloat? = nil,
            height: CGFloat? = nil
        ) {
            self.top = top
            self.bottom = bottom
            self.leading = leading
            self.trailing = trailing
            self.width = width
            self.height = height
        }

        init(horizontal: CGFloat? = nil, vertical: CGFloat? = nil) {
            self.top = vertical
            self.bottom = vertical
            self.leading = horizontal
            self.trailing = horizontal
        }

        init(all: CGFloat, width: CGFloat? = nil, height: CGFloat? = nil) {
            self.top = all
            self.bottom = all
            self.leading = all
            self.trailing = all
            self.width = width
            self.height = height
        }
    }
    
    struct CenterConstraints {
        var centerY: CGFloat?
        var centerX: CGFloat?
        
        init(centerY: CGFloat? = nil, centerX: CGFloat? = nil) {
            self.centerY = centerY
            self.centerX = centerX
        }
    }
    
    struct CenterConstraintsResult {
        var centerXConstraint: NSLayoutConstraint?
        var centerYConstraint: NSLayoutConstraint?
    }
    
    struct FrameConstraintsResult {
        var widthConstraint: NSLayoutConstraint?
        var heightConstraint: NSLayoutConstraint?
    }
    
    struct FrameConstraints {
        var width: CGFloat?
        var height: CGFloat?
        
        init(width: CGFloat? = nil, height: CGFloat? = nil) {
            self.width = width
            self.height = height
        }
    }

    enum ViewPosition {
        case center(width: CGFloat? = nil, height: CGFloat? = nil)
        case constraints(_ frameConstraints: AnchorConstraints)
    }

    func addAnchorConstraintsTo(view: UIView, constraints: AnchorConstraints) {
        view.translatesAutoresizingMaskIntoConstraints = false
        if let leadingValue = constraints.leading {
            view.leadingAnchor.constraint(equalTo: leadingAnchor, constant: leadingValue).isActive = true
        }
        if let topValue = constraints.top {
            view.topAnchor.constraint(equalTo: topAnchor, constant: topValue).isActive = true
        }
        if let trailingValue = constraints.trailing {
            trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: trailingValue).isActive = true
        }
        if let bottomValue = constraints.bottom {
            bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: bottomValue).isActive = true
        }
        if let widthValue = constraints.width {
            widthAnchor.constraint(equalTo: view.widthAnchor, constant: widthValue).isActive = true
        }
        if let heightValue = constraints.height {
            heightAnchor.constraint(equalTo: view.heightAnchor, constant: heightValue).isActive = true
        }
    }
    
    @discardableResult
    func addCenterConstraintsTo(view: UIView, constraints: CenterConstraints) -> CenterConstraintsResult {
        view.translatesAutoresizingMaskIntoConstraints = false
        var centerXConstraint: NSLayoutConstraint?
        var centerYConstraint: NSLayoutConstraint?
        if let centerX = constraints.centerX {
            centerXConstraint = view.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: centerX)
            centerXConstraint?.isActive = true
        }
        if let centerY = constraints.centerY {
            centerYConstraint = view.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: centerY)
            centerYConstraint?.isActive = true
        }
        return CenterConstraintsResult(
            centerXConstraint: centerXConstraint,
            centerYConstraint: centerYConstraint
        )
    }
    
    @discardableResult
    func addFrameConstraintsTo(constraints: FrameConstraints) -> FrameConstraintsResult {
        var widthConstraint: NSLayoutConstraint?
        var heightConstraint: NSLayoutConstraint?
        if let widthValue = constraints.width {
            widthConstraint = widthAnchor.constraint(equalToConstant: widthValue)
            widthConstraint?.isActive = true
        }
        if let heightValue = constraints.height {
            heightConstraint = heightAnchor.constraint(equalToConstant: heightValue)
            heightConstraint?.isActive = true
        }
        return FrameConstraintsResult(
            widthConstraint: widthConstraint,
            heightConstraint: heightConstraint
        )
    }
}
