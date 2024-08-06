//
//  StarsRatingView.swift
//  Redflix
//
//  Created by Volodymyr Mykhailiuk on 09.05.2024.
//

import UIKit

final class StarsRatingView: UIView {
    
    enum Constants {
        static let starActiveColor = AppColor.starActiveColor
        static let starInactiveColor = AppColor.starInactiveColor
    }
    
    // MARK: - Properties
    private let starSize: CGFloat
    private let spacing: CGFloat
    private var starsFrameConstraints: [FrameConstraintsResult] = []
    
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
    
    private lazy var stars: [UIImageView] = {
        (1...5).map {
            let imageView = UIImageView()
            imageView.image = UIImage(named: "starIcon")
            imageView.tag = $0
            imageView.translatesAutoresizingMaskIntoConstraints = false
            return imageView
        }
    }()
    
    // MARK: - Lifecycle
    init(starSize: CGFloat = 12, spacing: CGFloat = 4) {
        self.starSize = starSize
        self.spacing = spacing
        
        super.init(frame: .zero)
        
        setupViewHierarchy()
        setupConstraints()
        setupAppearance()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public
    func configure(with rating: Int) {
        stars.forEach {
            if rating >= $0.tag {
                $0.tintColor = Constants.starActiveColor
            } else {
                $0.tintColor = Constants.starInactiveColor
            }
        }
    }
    
    func configure(with starSize: CGFloat, spacing: CGFloat) {
        starsFrameConstraints.forEach {
            $0.heightConstraint?.constant = starSize
            $0.widthConstraint?.constant = starSize
        }
    }
}

// MARK: - UI Configurations
private extension StarsRatingView {
    func setupViewHierarchy() {
        addSubview(containerStackView)
        stars.forEach {
            containerStackView.addArrangedSubview($0)
        }
    }
    
    func setupConstraints() {
        containerStackView.addAnchorConstraintsTo(view: self, constraints: .init(all: 0))
        starsFrameConstraints = []
        stars.forEach {
            starsFrameConstraints.append(
                $0.addFrameConstraintsTo(
                    constraints: .init(width: starSize, height: starSize)
                )
            )
        }
    }
    
    func setupAppearance() {
        stars.forEach { $0.tintColor = Constants.starInactiveColor }
    }
}
