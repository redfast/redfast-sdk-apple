//
//  BadgeView.swift
//  Redflix
//
//  Created by Volodymyr Mykhailiuk on 10.05.2024.
//

import UIKit

final class BadgeView: UIView {
    enum Constants {
        static let bgColor = AppColor.brandOrangeColor
    }
    
    // MARK: - Subviews
    private lazy var textLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViewHierarchy()
        setupConstraints()
        setupAppearance()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = frame.height / 2
    }
    
    // MARK: - Public
    func configure(withText text: String) {
        textLabel.text = text
    }
    
    func configure(withFont font: UIFont) {
        textLabel.font = font
    }
}

// MARK: - UI Configurations
private extension BadgeView {
    func setupViewHierarchy() {
        addSubview(textLabel)
    }
    
    func setupConstraints() {
        textLabel.addCenterConstraintsTo(view: self, constraints: .init(centerY: 0, centerX: 0))
        textLabel.addAnchorConstraintsTo(view: self, constraints: .init(width: -24, height: 0))
    }
    
    func setupAppearance() {
        backgroundColor = Constants.bgColor
        layer.cornerRadius = frame.height / 2
        
        textLabel.textColor = .white
        textLabel.adjustsFontSizeToFitWidth = true
        textLabel.minimumScaleFactor = 0.5
    }
}
