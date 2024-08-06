//
//  MovieDetailsViewController.swift
//  Redflix
//
//  Created by Volodymyr Mykhailiuk on 16.05.2024.
//

import UIKit
import Combine

final class MovieDetailsViewController: UIViewController {
    enum Constants {
        static let bgColor = AppColor.contentBGColor
        static let secondaryTextColor = AppColor.secondaryTextColor
        static let imageMultiplier: CGFloat = 0.4945
        static let quote1Text = "Christopher Nolan's space exploration epic is serious science fiction with brains, beauty and heart. In the age of shopping-centre cinema, Christopher Nolan builds cathedrals. His films are cold, enormous, sky-puncturing constructions, echoey with triumphant gloom, rippling with the gasps and whispers of the faithful."
        static let descriptionText1 = "He’s the preeminent blockbuster auteur of our time, a fiercely rational puzzle-maker and problem-solver; the Mies van der Rohe of Hollywood. He prefers shooting on film to digital cameras, and strives to achieve special effects on set rather than at a computer-graphics workstation. The rotating hotel corridor scene in Inception – a fist-fight in which the combatants spin and click together like the workings of a combination lock – is Nolan’s vision of cinema in miniature. Depending on which critic you talk to, he’s either a throwback, a fusspot and an ideologue, or the spiritual offspring of Steven Spielberg and Stanley Kubrick. (Of course, there’s no reason he can’t be all of the above.)"
        static let headerText1 = "A unique intro to the movie"
        static let descriptionText2 = "Like Kubrick, he has a reputation for chilliness, and none of his films are ever likely to be mistaken for romantic comedy. Memento, his 2000 breakthrough hit, is about the vagaries of truth and memory, while his recent Batman trilogy, which culminated two years ago in The Dark Knight Rises, deals with order and chaos, and society’s schizophrenic craving for both. No other filmmaker working today is as determined to use blockbuster spectacle to say something big about our world – even as he sends his characters zooming away from it, through wormholes, at light-speed."
        static let descriptionText3 = "A scene from Christopher Nolan's 'Interstellar' A scene from Christopher Nolan's 'Interstellar' Credit: Melinda Sue Gordon Interstellar is Nolan’s best and most brazenly ambitious film to date. Doubling down on the Kubrick comparisons, he’s made his own sweeping space odyssey in which a team of astronauts, led by Matthew McConaughey’s stoically smouldering Coop, venture into the great beyond in search of a new home for humanity. Starlight whirls, planets rock on their axes, and spacecraft cartwheel through nothingness, all soundtracked by a reverential Hans Zimmer score that’s equal parts Johann Strauss and Philip Glass.\n\nThe film takes place in the near future, with Earth in the grip of The Blight, an airborne disease that causes food crops to turn to grey-brown powder. It rolls and billows across the land, piling up around houses and cars like the dust-drifts in Andrei Tarkovsky’s Stalker, another film in which the characters slip between time’s cogs."
        static let headerText2 = "The ending of the movie is an amazing experience"
        static let descriptionText4 = "Coop (the allusion to Gary Cooper is vigorously intended) is a former Nasa pilot who’s pitching in with the dig for victory effort, although for him the plan to sit out the famine lacks ambition – and therefore humanity."
        static let quote2Text = "We used to look up and wonder about our place in the stars,” he grumbles. “Now we just look down and worry about our place in the dirt."
        static let descriptionText5 = "The catch is that, on the far side of the wormhole, with the planets on the lip of an enormous black hole, time is far more stretched out than it is on Earth, with years, even decades, flashing past in an hour or two. This turns Coop’s quest into a heartbreaking inversion of C. S. Lewis’s Chronicles of Narnia: the real world doesn’t freeze while his adventure unfolds, making childhood last a lifetime, but slips away quicker than ever."
        static let descriptionText6 = "Jessica Chastain and Casey Affleck star in Christopher Nolan's 'Interstellar' Jessica Chastain and Casey Affleck star in Christopher Nolan's 'Interstellar' Credit: Melinda Sue Gordon But at first, it’s Coop that destiny comes calling for. The strange force in Murph’s room points him towards a restricted airbase where his former Nasa boss Dr. Brand (Michael Caine), is captaining the ‘Lazarus Project’: a secret search for a new habitable planet. “We’re not meant to save the world, we’re meant to leave it,” he explains – a belief bolstered by the recent appearance of a mysterious wormhole near one of Saturn’s moons, through which a cluster of potentially suitable planets have been glimpsed.\n\nThe catch is that, on the far side of the wormhole, with the planets on the lip of an enormous black hole, time is far more stretched out than it is on Earth, with years, even decades, flashing past in an hour or two. This turns Coop’s quest into a heartbreaking inversion of C. S. Lewis’s Chronicles of Narnia: the real world doesn’t freeze while his adventure unfolds, making childhood last a lifetime, but slips away quicker than ever."
    }
    
    // MARK: - Properties
    private var cancellable = Set<AnyCancellable>()
    private let viewModel: MovieDetailsViewModel
    private var layoutType: LayoutType {
        UIDevice.current.userInterfaceIdiom == .phone ? .phone : .landscape
    }
    private let focusGuide = UIFocusGuide()
    
    // MARK: - Subviews
    private lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.contentInset = .init(top: 0, left: 0, bottom: 16, right: 0)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var topSpacerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var containerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .center
        stackView.spacing = 30
        return stackView
    }()
    
    private lazy var headerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = layoutType == .phone ? .vertical : .horizontal
        stackView.distribution = .fill
        stackView.alignment = layoutType == .phone ? .center : .top
        stackView.spacing = 30
        return stackView
    }()
    
    private lazy var contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .leading
        stackView.spacing = 30
        return stackView
    }()
    
    private lazy var extendedInfoStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .center
        stackView.spacing = 30
        return stackView
    }()
    
    private lazy var badgeView: BadgeView = {
        let view = BadgeView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var movieImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var bgMovieImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var gradientView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
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
    
    private lazy var starsRatingView: StarsRatingView = {
        let view = StarsRatingView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var categoryView: IconLabelView = {
        let view = IconLabelView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var timeView: IconLabelView = {
        let view = IconLabelView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var shortDescriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var durationLabelView: ValueLabelView = {
        let label = ValueLabelView(fontSize: 14, spacing: 8)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var directorLabelView: ValueLabelView = {
        let label = ValueLabelView(fontSize: 14, spacing: 8)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var quote1View: UIView = {
        let view = QuoteView()
        view.configure(with: Constants.quote1Text)
        view.translatesAutoresizingMaskIntoConstraints = false
#if os(tvOS)
        let buttonContainer = UIButton()
        buttonContainer.addSubview(view)
        buttonContainer.addAnchorConstraintsTo(view: view, constraints: .init(all: 0))
        return buttonContainer
#else
        return view
#endif
    }()
    
    private lazy var headerLabel1: UILabel = {
        let label = UILabel()
        label.text = Constants.headerText1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var movieDetailsImageView1: UIView = {
        let view = UIImageView(image: UIImage(named: "movieDetails1"))
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var headerLabel2: UILabel = {
        let label = UILabel()
        label.text = Constants.headerText2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var quote2View: UIView = {
        let view = QuoteView()
        view.configure(with: Constants.quote2Text)
        view.translatesAutoresizingMaskIntoConstraints = false
#if os(tvOS)
        let buttonContainer = UIButton()
        buttonContainer.addSubview(view)
        buttonContainer.addAnchorConstraintsTo(view: view, constraints: .init(all: 0))
        return buttonContainer
#else
        return view
#endif
    }()
    
    private lazy var movieDetailsImageView2: UIView = {
        let view = UIImageView(image: UIImage(named: "movieDetails2"))
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var gradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.colors = [
            Constants.bgColor.withAlphaComponent(0.7).cgColor,
            Constants.bgColor.withAlphaComponent(0.9).cgColor
        ]
        layer.startPoint = .init(x: 0.5, y: 0)
        layer.endPoint = .init(x: 0.5, y: 1)
        return layer
    }()
    
    // MARK: - Lifecycle
    init(viewModel: MovieDetailsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViewHierarchy()
        setupConstraints()
        setupAppearance()
        setupBindings()
        
        Task {
            await viewModel.setup()
            viewModel.registerScreen(self)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        gradientLayer.frame = gradientView.bounds
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            self.gradientLayer.frame = self.gradientView.bounds
        }
    }
    
    // MARK: - Private
    private func descriptionLabel(_ text: String) -> UIView {
        let label = UILabel()
        label.numberOfLines = .zero
        label.textColor = Constants.secondaryTextColor
        label.font = .custom(
            type: .robotoRegular,
            ofSize: layoutType == .phone ? 14 : 16
        )
        label.text = text
        label.translatesAutoresizingMaskIntoConstraints = false
#if os(tvOS)
        let buttonContainer = UIButton()
        buttonContainer.addSubview(label)
        buttonContainer.addAnchorConstraintsTo(view: label, constraints: .init(all: 0))
        return buttonContainer
#else
        return label
#endif
    }
}

// MARK: - Configurations
extension MovieDetailsViewController {
    func setupViewHierarchy() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(bgMovieImageView)
        bgMovieImageView.addSubview(gradientView)
        gradientView.layer.insertSublayer(gradientLayer, at: 0)
        contentView.addSubview(containerStackView)
        containerStackView.addArrangedSubviews([
            topSpacerView,
            headerStackView,
            contentStackView
        ])
        
        contentStackView.addArrangedSubviews([
            quote1View,
            descriptionLabel(Constants.descriptionText1),
            headerLabel1,
            descriptionLabel(Constants.descriptionText2),
            movieDetailsImageView1,
            descriptionLabel(Constants.descriptionText3),
            headerLabel2,
            descriptionLabel(Constants.descriptionText4),
            quote2View,
            descriptionLabel(Constants.descriptionText5),
            movieDetailsImageView2,
            descriptionLabel(Constants.descriptionText6)
        ])
        
        headerStackView.addArrangedSubviews([
            movieImageView,
            extendedInfoStackView
        ])
        
        extendedInfoStackView.addArrangedSubviews([
            nameLabel,
            infoStackView,
            shortDescriptionLabel,
            durationLabelView,
            directorLabelView
        ])
        
        infoStackView.addArrangedSubviews([
            starsRatingView,
            categoryView,
            timeView
        ])
        contentView.addSubview(badgeView)
    }
    
    func setupConstraints() {
        view.addAnchorConstraintsTo(
            view: scrollView,
            constraints: .init(all: 0)
        )
        scrollView.addAnchorConstraintsTo(
            view: contentView,
            constraints: .init(all: 0, width: 0)
        )
        topSpacerView.addFrameConstraintsTo(constraints: .init(height: 46))
        contentView.addAnchorConstraintsTo(
            view: bgMovieImageView,
            constraints: .init(top: 0, leading: 0, trailing: 0)
        )
        bgMovieImageView.addAnchorConstraintsTo(view: gradientView, constraints: .init(all: 0))
        bgMovieImageView.addFrameConstraintsTo(constraints: .init(height: UIScreen.main.bounds.height / 2))
        contentView.addAnchorConstraintsTo(
            view: containerStackView,
            constraints: .init(vertical: 0)
        )
        contentView.addCenterConstraintsTo(view: containerStackView, constraints: .init(centerX: 0))
        headerStackView.addFrameConstraintsTo(constraints: .init(width: min(800, UIScreen.main.bounds.width - 32)))
        contentStackView.addFrameConstraintsTo(constraints: .init(width: min(600, UIScreen.main.bounds.width - 32)))
        
        let imageWidth: CGFloat = layoutType == .phone ? 240 : 350
        movieImageView.addFrameConstraintsTo(constraints: .init(width: imageWidth, height: imageWidth / 0.69))
        let badgeSize: CGFloat = imageWidth * 0.2
        badgeView.addFrameConstraintsTo(constraints: .init(width: badgeSize, height: badgeSize))
        movieImageView.addAnchorConstraintsTo(view: badgeView, constraints: .init(top: -badgeSize / 3, leading: -badgeSize / 3))
        
        movieDetailsImageView1.heightAnchor.constraint(
            equalTo: movieDetailsImageView1.widthAnchor,
            multiplier: Constants.imageMultiplier
        ).isActive = true
        
        movieDetailsImageView2.heightAnchor.constraint(
            equalTo: movieDetailsImageView2.widthAnchor,
            multiplier: Constants.imageMultiplier
        ).isActive = true
    }
    
    func setupAppearance() {
        navigationItem.applyBrandNavigationTitle()
        view.backgroundColor = Constants.bgColor
        
        movieImageView.clipsToBounds = true
        movieImageView.layer.cornerRadius = 12
        badgeView.configure(withFont: .custom(type: .catamaranExtraBold, ofSize: layoutType == .phone ? 18 : 32))
        
        nameLabel.font = .custom(type: .catamaranExtraBold, ofSize: 32)
        nameLabel.numberOfLines = .zero
        nameLabel.textColor = .white
        
        [categoryView, timeView].forEach {
            $0.configure(
                withSize: layoutType == .phone ? 12 : 20,
                andFont: layoutType == .phone ? 10 : 16
            )
        }
        
        shortDescriptionLabel.textColor = .white
        shortDescriptionLabel.numberOfLines = .zero
        shortDescriptionLabel.textAlignment = .center
        shortDescriptionLabel.font = .custom(type: .catamaranBold, ofSize: 16)
        
        [headerLabel1, headerLabel2].forEach { label in
            label.textColor = .white
            label.numberOfLines = .zero
            label.font = .custom(type: .catamaranExtraBold, ofSize: 24)
        }
        containerStackView.setCustomSpacing(0, after: topSpacerView)
        extendedInfoStackView.setCustomSpacing(16, after: nameLabel)
        extendedInfoStackView.setCustomSpacing(16, after: infoStackView)
        extendedInfoStackView.setCustomSpacing(10, after: durationLabelView)
        contentStackView.setCustomSpacing(16, after: headerLabel1)
    }
    
    func setupBindings() {
        viewModel.$imageData
            .sink { [weak self] data in
                guard let self, let data else { return }
                self.movieImageView.image = UIImage(data: data)
            }
            .store(in: &cancellable)
        
        viewModel.$landscapeImageData
            .sink { [weak self] data in
                guard let self, let data else { return }
                self.bgMovieImageView.image = UIImage(data: data)
            }
            .store(in: &cancellable)
        
        viewModel.$ratingString
            .sink { [weak self] in
                self?.badgeView.configure(withText: $0)
            }
            .store(in: &cancellable)
        
        viewModel.$movieName
            .sink { [weak self] in
                self?.nameLabel.text = $0
            }
            .store(in: &cancellable)
        
        viewModel.$category
            .sink { [weak self] in
                self?.categoryView.configure(
                    with: UIImage(systemName: "tag"),
                    and: $0
                )
            }
            .store(in: &cancellable)
        
        viewModel.$releaseDate
            .sink { [weak self] in
                self?.timeView.configure(
                    with: UIImage(systemName: "clock"),
                    and: $0
                )
            }
            .store(in: &cancellable)
        
        viewModel.$movieStarRating
            .sink { [weak self] rating in
                guard let self, let rating else { return }
                self.starsRatingView.configure(with: rating)
            }
            .store(in: &cancellable)
        
        viewModel.$movieDescription
            .sink { [weak self] in
                self?.shortDescriptionLabel.text = $0
            }
            .store(in: &cancellable)
        
        viewModel.$duration
            .sink { [weak self] in
                self?.durationLabelView.configure(with: "Duration:", and: $0)
            }
            .store(in: &cancellable)
        
        viewModel.$director
            .sink { [weak self] in
                self?.directorLabelView.configure(with: "Director:", and: $0)
            }
            .store(in: &cancellable)
    }
}

// MARK: - PromotionViewProtocol
extension MovieDetailsViewController: PromotionViewProtocol {
    var name: String { "MovieDetailsViewController" }
}
