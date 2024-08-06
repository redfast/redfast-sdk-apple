//
//  BannerView.swift
//  Redflix
//
//  Created by Volodymyr Mykhailiuk on 30.05.2024.
//

import UIKit

final class BannerView: UIView {
    
    // MARK: - Subviews
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.clipsToBounds = true
        return imageView
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
    
    func configure(with image: UIImage?) {
        imageView.image = image
    }
}

// MARK: - Configurations
private extension BannerView {
    func setupViewHierarchy() {
        addSubview(imageView)
    }
    
    func setupConstraints() {
        addAnchorConstraintsTo(view: imageView, constraints: .init(all: 0))
    }
    
    func setupAppearance() {
#if os(tvOS)
        imageView.adjustsImageWhenAncestorFocused = true
        imageView.clipsToBounds = false
#endif
    }
}
