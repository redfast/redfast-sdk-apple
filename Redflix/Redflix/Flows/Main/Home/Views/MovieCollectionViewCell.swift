//
//  MovieCollectionViewCell.swift
//  Redflix
//
//  Created by Volodymyr Mykhailiuk on 07.05.2024.
//

import UIKit

final class MovieCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Properties
    private var badgeCenterY: NSLayoutConstraint?
    
    // MARK: - Subviews
    private lazy var contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .leading
        stackView.spacing = 4
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var topSpacerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var badgeView: BadgeView = {
        let view = BadgeView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var starsRatingView: StarsRatingView = {
        let view = StarsRatingView(starSize: 8, spacing: 2)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var categoryView: IconLabelView = {
        let view = IconLabelView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
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
    
    // MARK: - Internal
    func configure(with image: UIImage?) {
        imageView.image = image
    }
    
    func configure(with vm: MovieRowViewModel, layoutType: LayoutType) {
        badgeView.configure(withText: String(vm.rating))
        badgeView.configure(withFont: .custom(type: .catamaranExtraBold, ofSize: layoutType == .phone ? 10 : 24))
        
        starsRatingView.configure(with: vm.starRating)
        starsRatingView.configure(
            with: layoutType == .phone ? 8 : 16,
            spacing: layoutType == .phone ? 2 : 4
        )
        categoryView.configure(
            with: UIImage(systemName: "tag"),
            and: vm.category.name
        )
        categoryView.configure(
            withSize: layoutType == .phone ? 12 : 20,
            andFont: layoutType == .phone ? 10 : 12
        )
        nameLabel.font = .custom(type: .catamaranExtraBold, ofSize: layoutType == .phone ? 12 : 14)
        contentStackView.spacing = layoutType == .phone ? 4 : 8
        nameLabel.text = vm.name
        
        startImageLoading(vm)
    }
    
    // MARK: - Private
    private func startImageLoading(_ vm: MovieRowViewModel) {
        Task {
            let data = await vm.loadImageData()
            if let data, let image = UIImage(data: data) {
                await MainActor.run {
                    configure(with: image)
                }
            }
        }
    }
}

// MARK: - UI Configuration
extension MovieCollectionViewCell {
    func setupViewHierarchy() {
        contentView.addSubview(contentStackView)
        contentView.addSubview(badgeView)
        contentStackView.addArrangedSubview(topSpacerView)
        contentStackView.addArrangedSubview(imageView)
        contentStackView.addArrangedSubview(starsRatingView)
        contentStackView.addArrangedSubview(nameLabel)
        contentStackView.addArrangedSubview(categoryView)
    }
    
    func setupConstraints() {
        contentView.addAnchorConstraintsTo(
            view: contentStackView,
            constraints: .init(all: 0)
        )
        
        badgeView.addCenterConstraintsTo(
            view: imageView,
            constraints: .init(centerX: 0)
        )
        
        badgeView.centerYAnchor.constraint(equalTo: imageView.topAnchor).isActive = true
        topSpacerView.addFrameConstraintsTo(constraints: .init(height: 20))
    }
    
    func setupAppearance() {

        contentStackView.setCustomSpacing(0, after: topSpacerView)
        nameLabel.font = .custom(type: .catamaranExtraBold, ofSize: 12)
        nameLabel.textColor = .white
#if os(tvOS)
        imageView.adjustsImageWhenAncestorFocused = true
        clipsToBounds = false
#endif
    }
}
