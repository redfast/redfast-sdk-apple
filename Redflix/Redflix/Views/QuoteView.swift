//
//  QuoteView.swift
//  Redflix
//
//  Created by Volodymyr Mykhailiuk on 16.05.2024.
//

import UIKit

final class QuoteView: UIView {
    enum Constants {
        static let bgColor = AppColor.brandGrayColor
        static let bookmarkColor = AppColor.brandOrangeColor
    }
    
    // MARK: - Subviews
    private lazy var verticalView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var quoteLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Lifecycle
    init() {
        super.init(frame: .zero)
        
        setupViewHierarchy()
        setupConstraints()
        setupAppearance()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public
    func configure(with text: String) {
        quoteLabel.text = "\"\(text)\""
    }
}

// MARK: - UI Configurations
private extension QuoteView {
    func setupViewHierarchy() {
        addSubview(verticalView)
        addSubview(quoteLabel)
    }
    
    func setupConstraints() {
        verticalView.addAnchorConstraintsTo(view: self, constraints: .init(top: 0, bottom: 0, leading: 0))
        verticalView.addFrameConstraintsTo(constraints: .init(width: 4))
        
        quoteLabel.addAnchorConstraintsTo(view: self, constraints: .init(all: -16))
    }
    
    func setupAppearance() {
        backgroundColor = Constants.bgColor
        verticalView.backgroundColor = Constants.bookmarkColor
        quoteLabel.textColor = .white
        quoteLabel.numberOfLines = .zero
        quoteLabel.font = .custom(type: .catamaranBold, ofSize: 20)
    }
}
