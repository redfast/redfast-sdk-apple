//
//  IconLabelView.swift
//  Redflix
//
//  Created by Volodymyr Mykhailiuk on 09.05.2024.
//

import UIKit

final class IconLabelView: UIView {
    
    enum Constants {
        static let iconColor = AppColor.brandOrangeColor
    }
    
    // MARK: - Properties
    private var iconFrameConstraint: FrameConstraintsResult?
    
    // MARK: - Subviews
    private lazy var containerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = 4
        return stackView
    }()
    
    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
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
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public
    func configure(with icon: UIImage?, and text: String?) {
        iconImageView.image = icon
        titleLabel.text = text
    }
    
    func configure(withSize iconSize: CGFloat, andFont fontSize: CGFloat) {
        titleLabel.font = .custom(type: .robotoRegular, ofSize: fontSize)
        iconFrameConstraint?.heightConstraint?.constant = iconSize
        iconFrameConstraint?.widthConstraint?.constant = iconSize
    }
}

// MARK: - UI Configurations
private extension IconLabelView {
    func setupViewHierarchy() {
        addSubview(containerStackView)
        containerStackView.addArrangedSubview(iconImageView)
        containerStackView.addArrangedSubview(titleLabel)

    }
    
    func setupConstraints() {
        containerStackView.addAnchorConstraintsTo(view: self, constraints: .init(all: 0))
        iconFrameConstraint = iconImageView.addFrameConstraintsTo(constraints: .init(width: 12, height: 12))
    }
    
    func setupAppearance() {
        iconImageView.tintColor = Constants.iconColor
        titleLabel.textColor = .white
        titleLabel.font = .custom(type: .robotoRegular, ofSize: 10)
    }
}
