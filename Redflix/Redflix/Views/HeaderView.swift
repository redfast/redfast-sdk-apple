//
//  HeaderView.swift
//  Redflix
//
//  Created by Volodymyr Mykhailiuk on 09.05.2024.
//

import UIKit

final class HeaderView: UIView {
    
    // MARK: - Properties
    private let layoutType: LayoutType
    
    // MARK: - Subviews
    private lazy var containerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 8
        return stackView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Lifecycle
    init(layoutType: LayoutType) {
        self.layoutType = layoutType
        super.init(frame: .zero)
        
        setupViewHierarchy()
        setupConstraints()
        setupAppearance()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public
    func configure(with title: String?, subtitle: String?) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
    }
}

// MARK: - UI Configurations
private extension HeaderView {
    func setupViewHierarchy() {
        addSubview(containerStackView)
        containerStackView.addArrangedSubview(titleLabel)
        containerStackView.addArrangedSubview(subtitleLabel)
    }
    
    func setupConstraints() {
        containerStackView.addAnchorConstraintsTo(view: self, constraints: .init(all: 0))
    }
    
    func setupAppearance() {
        titleLabel.textColor = .white
        titleLabel.font = .custom(
            type: .catamaranExtraBold,
            ofSize: layoutType == .phone ? 28 : 42
        )
        subtitleLabel.textColor = AppColor.secondaryTextColor
        subtitleLabel.font = .custom(
            type: .robotoRegular,
            ofSize: layoutType == .phone ? 12 : 18
        )
    }
}
