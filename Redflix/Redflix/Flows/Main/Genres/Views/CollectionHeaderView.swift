//
//  CollectionHeaderView.swift
//  Redflix
//
//  Created by Volodymyr Mykhailiuk on 21.05.2024.
//

import UIKit

final class CollectionHeaderView: UICollectionReusableView {
    
    static let supplementaryViewKind = "CollectionHeaderView"
    
    // MARK: - Subviews
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        return label
    }()
    
    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViewHierarchy()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Internal
    func configure(withText text: String) {
        titleLabel.text = text
    }
    
    func configure(withFont font: UIFont) {
        titleLabel.font = font
    }
    
    // MARK: - Private
    private func setupViewHierarchy() {
        addSubview(titleLabel)
    }
    
    private func setupConstraints() {
        addAnchorConstraintsTo(view: titleLabel, constraints: .init(bottom: 0, leading: 0, trailing: 0))
    }
}
