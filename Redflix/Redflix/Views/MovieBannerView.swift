//
//  MovieBannerView.swift
//  Redflix
//
//  Created by Volodymyr Mykhailiuk on 09.05.2024.
//

import UIKit

final class MovieBannerView: UIView {
    
    // MARK: - Properties
    private let layoutType: LayoutType
    private var onButtonTapped: (() -> Void)?
    
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
    
    private lazy var badgeStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .leading
        stackView.distribution = .fill
        return stackView
    }()
    
    private lazy var badgeView: BadgeView = {
        let view = BadgeView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "silentHill")
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var starsRatingView: StarsRatingView = {
        let view = StarsRatingView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Silent Hill"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var descriptionStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        return stackView
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 4
        label.text = "The film takes place in the near future, with Earth in the grip of The Blight, an airborne disease that causes food crops to turn to grey-brown powder. It rolls and billows across the land, piling up around houses and cars like the dust-drifts in Andrei Tarkovsky’s Stalker, another film in which the characters slip between time’s cogs."
        label.lineBreakMode = .byTruncatingTail
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var infoStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.spacing = 8
        return stackView
    }()
    
    private lazy var categoryIconView: IconLabelView = {
        let view = IconLabelView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var timeIconView: IconLabelView = {
        let view = IconLabelView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var actionsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .top
        stackView.distribution = .fill
        return stackView
    }()
    
    private lazy var readMoreButton: UIButton = {
        let button = UIButton(type: .system)
        var configuration = UIButton.Configuration.plain()
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 12, bottom: 0, trailing: 12)
        button.configuration = configuration
        button.addTarget(self, action: #selector(buttonTapped), for: .primaryActionTriggered)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var directorLabel: UILabel = {
        let label = UILabel()
        label.text = "Jonathan\nLewis"
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Lifecycle
    init(layoutType: LayoutType, onButtonTapped: (() -> Void)?) {
        self.layoutType = layoutType
        self.onButtonTapped = onButtonTapped
        super.init(frame: .zero)
        
        setupViewHierarchy()
        setupConstraints()
        setupAppearance()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public
    func configure() {
        starsRatingView.configure(with: 3)
        starsRatingView.configure(
            with: layoutType == .phone ? 12 : 24,
            spacing: layoutType == .phone ? 4 : 8
        )
        categoryIconView.configure(with: UIImage(systemName: "tag"), and: "Thriller")
        timeIconView.configure(with: UIImage(systemName: "clock"), and: "October 29, 2017")
        [categoryIconView, timeIconView].forEach {
            $0.configure(
                withSize: layoutType == .phone ? 12 : 20,
                andFont: layoutType == .phone ? 10 : 16
            )
        }
        badgeView.configure(withText: "9,6")
        badgeView.configure(withFont: .custom(type: .catamaranExtraBold, ofSize: layoutType == .phone ? 18 : 32))
        titleLabel.font = .custom(type: .catamaranExtraBold, ofSize: layoutType == .phone ? 28 : 40)
    }
    
    // MARK: - Actions
    @objc private func buttonTapped() {
        onButtonTapped?()
    }
}

// MARK: - UI Configurations
private extension MovieBannerView {
    func setupViewHierarchy() {
        addSubview(backgroundImageView)
        addSubview(containerStackView)
        
        containerStackView.addArrangedSubview(UIView())
        
        containerStackView.addArrangedSubview(badgeStackView)
        containerStackView.addArrangedSubview(titleLabel)
        containerStackView.addArrangedSubview(infoStackView)
        if layoutType == .landscape {
            containerStackView.addArrangedSubview(descriptionStackView)
        }
        containerStackView.addArrangedSubview(actionsStackView)
        containerStackView.addArrangedSubview(UIView())
        
        badgeStackView.addArrangedSubview(badgeView)
        badgeStackView.addArrangedSubview(UIView())
        
        infoStackView.addArrangedSubview(starsRatingView)
        infoStackView.addArrangedSubview(categoryIconView)
        infoStackView.addArrangedSubview(timeIconView)
        infoStackView.addArrangedSubview(UIView())
        
        descriptionStackView.addArrangedSubview(descriptionLabel)
        descriptionStackView.addArrangedSubview(UIView())
        
        actionsStackView.addArrangedSubview(readMoreButton)
        actionsStackView.addArrangedSubview(UIView())
        actionsStackView.addArrangedSubview(directorLabel)
    }
    
    func setupConstraints() {
        backgroundImageView.addAnchorConstraintsTo(view: self, constraints: .init(all: 0))
        containerStackView.addCenterConstraintsTo(view: self, constraints: .init(centerY: 0, centerX: 0))
        if layoutType == .phone {
            containerStackView.addAnchorConstraintsTo(view: self, constraints: .init(horizontal: -16))
        } else {
            containerStackView.addFrameConstraintsTo(constraints: .init(width: UIScreen.main.bounds.width / 2))
            descriptionLabel.addFrameConstraintsTo(constraints: .init(width: UIScreen.main.bounds.width / 4))
        }
        readMoreButton.addFrameConstraintsTo(constraints: .init(height: 42))
    }
    
    func setupAppearance() {
        titleLabel.textColor = .white
        titleLabel.font = .custom(type: .catamaranExtraBold, ofSize: 28)
        
        descriptionLabel.textColor = .white
        descriptionLabel.font = .custom(type: .robotoRegular, ofSize: 16)
        descriptionLabel.setLineSpacing(lineSpacing: 5)
        
        readMoreButton.backgroundColor = .clear
        readMoreButton.layer.borderColor = UIColor.white.cgColor
        readMoreButton.layer.borderWidth = 2.0
        readMoreButton.layer.cornerRadius = 4
        let attributedTitle = NSAttributedString(
            string: "READ MORE",
            attributes: [
                NSAttributedString.Key.font: UIFont.custom(
                    type: .catamaranExtraBold,
                    ofSize: layoutType == .phone ? 12 : 18
                ),
                NSAttributedString.Key.foregroundColor: UIColor.white
            ]
        )
        readMoreButton.setAttributedTitle(attributedTitle, for: .normal)
        
        directorLabel.textColor = .white
        directorLabel.numberOfLines = 0
        directorLabel.textAlignment = .left
        directorLabel.font = .custom(
            type: .catamaranExtraBold,
            ofSize: layoutType == .phone ? 12 : 18
        )
    }
}
