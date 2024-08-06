//
//  ValueLabelView.swift
//  Redflix
//
//  Created by Volodymyr Mykhailiuk on 16.05.2024.
//

import UIKit

final class ValueLabelView: UIView {
    
    // MARK: - Properties
    private let fontSize: CGFloat
    private let spacing: CGFloat
    
    // MARK: - Subviews
    private lazy var containerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = spacing
        return stackView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var valueLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Lifecycle
    init(fontSize: CGFloat, spacing: CGFloat) {
        self.fontSize = fontSize
        self.spacing = spacing
        super.init(frame: .zero)
        
        setupViewHierarchy()
        setupConstraints()
        setupAppearance()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Internal
    func configure(with title: String?, and value: String?) {
        titleLabel.text = title
        valueLabel.text = value
    }
}

// MARK: - UI Configurations
private extension ValueLabelView {
    func setupViewHierarchy() {
        addSubview(containerStackView)
        containerStackView.addArrangedSubview(titleLabel)
        containerStackView.addArrangedSubview(valueLabel)
    }
    
    func setupConstraints() {
        containerStackView.addAnchorConstraintsTo(view: self, constraints: .init(all: 0))
    }
    
    func setupAppearance() {
        titleLabel.textColor = .white
        titleLabel.font = .custom(type: .robotoBold, ofSize: fontSize)
        
        valueLabel.textColor = .white
        valueLabel.font = .custom(type: .robotoRegular, ofSize: fontSize)
    }
}
