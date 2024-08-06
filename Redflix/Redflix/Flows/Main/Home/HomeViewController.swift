//
//  HomeViewController.swift
//  Redflix
//
//  Created by Volodymyr Mykhailiuk on 03.05.2024.
//

import UIKit
import Combine

enum HomeCollectionViewType: Int {
    case movies = 1000
    case new
}

enum LayoutType {
    case phone
    case landscape
}

protocol PromotionViewProtocol {
    var name: String { get }
}

final class HomeViewController: UIViewController {
    enum Constants {
        static let bgColor = AppColor.contentBGColor
        static let newReleasesTitle = "New Releases"
        static let newReleasesSubtitle = "Our most recently released reviews."
        static let highlightsTitle = "Highlights today"
        static let highlightsSubtitle = "Be sure not to miss these reviews today."
    }
    
    // MARK: - Properties
    private var cancellable = Set<AnyCancellable>()
    private let viewModel: HomeViewModel
    private let collectionViewSize: CGSize
    private let newReleasesCollectionViewSize: CGSize
    private var layoutType: LayoutType {
        UIDevice.current.userInterfaceIdiom == .phone ? .phone : .landscape
    }
    
    // MARK: - Subviews
    private lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.contentInset = .init(top: 16, left: 0, bottom: 16, right: 0)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var containerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.spacing = 12
        return stackView
    }()
    
    private lazy var headerView: UIView = {
        let view = HeaderView(layoutType: layoutType)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.configure(with: Constants.highlightsTitle, subtitle: Constants.highlightsSubtitle)
        return view
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = collectionViewSize
        layout.sectionInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(cell: MovieCollectionViewCell.self)
        collectionView.tag = HomeCollectionViewType.movies.rawValue
        return collectionView
    }()
    
    private lazy var bannerView: UIView = {
        let view = MovieBannerView(layoutType: layoutType) { [weak self] in
            self?.viewModel.readMore()
        }
        view.configure()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var newReleasesHeaderView: UIView = {
        let view = HeaderView(layoutType: layoutType)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.configure(with: Constants.newReleasesTitle, subtitle: Constants.newReleasesSubtitle)
        return view
    }()
    
    private lazy var gradientView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var newReleasesCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = newReleasesCollectionViewSize
        layout.sectionInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(cell: MovieCollectionViewCell.self)
        collectionView.tag = HomeCollectionViewType.new.rawValue
        return collectionView
    }()
    
    private lazy var gradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.colors = [
            Constants.bgColor.withAlphaComponent(0.1).cgColor,
            Constants.bgColor.cgColor
        ]
        layer.startPoint = .init(x: 0.5, y: 0)
        layer.endPoint = .init(x: 0.5, y: 1)
        return layer
    }()
    
    // MARK: - Lifecycle
    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
        
        let moviesWidth = min(UIScreen.main.bounds.width / 4 - 12, 270)
        let moviesHeight = min(max(moviesWidth / 0.57, 200), 462)
        self.collectionViewSize = CGSize(width: moviesWidth, height: moviesHeight)
        
        let newReleasesWidth = min(UIScreen.main.bounds.width / 2 - 12, 480)
        let newReleasesHeight = min(newReleasesWidth * 0.72, 342)
        self.newReleasesCollectionViewSize = CGSize(width: newReleasesWidth, height: newReleasesHeight)
        
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
            try? await viewModel.setup()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        gradientLayer.frame = gradientView.bounds
        viewModel.registerScreen(self)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.gradientLayer.frame = self.gradientView.bounds
        }
    }
    
    // MARK: - Configurations
    private func setupViewHierarchy() {
        view.addSubview(scrollView)
        scrollView.addSubview(containerStackView)
        containerStackView.addArrangedSubview(headerView)
        containerStackView.addArrangedSubview(collectionView)
        containerStackView.addArrangedSubview(bannerView)
        bannerView.addSubview(gradientView)
        gradientView.addSubview(newReleasesHeaderView)
        containerStackView.addArrangedSubview(newReleasesCollectionView)
        gradientView.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    private func setupConstraints() {
        view.addAnchorConstraintsTo(
            view: scrollView,
            constraints: .init(all: 0)
        )
        scrollView.addAnchorConstraintsTo(
            view: containerStackView,
            constraints: .init(all: 0, width: 0)
        )
        
        collectionView.addFrameConstraintsTo(constraints: .init(height: collectionViewSize.height))
        bannerView.addFrameConstraintsTo(constraints: .init(height: layoutType == .phone ? 400 : 500))
        newReleasesCollectionView.addFrameConstraintsTo(constraints: .init(height: newReleasesCollectionViewSize.height))
        bannerView.addAnchorConstraintsTo(
            view: gradientView,
            constraints: .init(bottom: 0, leading: 0, trailing: 0)
        )
        gradientView.addAnchorConstraintsTo(
            view: newReleasesHeaderView,
            constraints: .init(all: 0)
        )
    }
    
    private func setupAppearance() {
        navigationItem.applyBrandNavigationTitle()
        view.backgroundColor = Constants.bgColor
        collectionView.backgroundColor = .clear
        newReleasesCollectionView.backgroundColor = .clear
    }
    
    private func setupBindings() {
        viewModel.$movies
            .sink { [weak self] rows in
                self?.collectionView.reloadData()
            }
            .store(in: &cancellable)
        
        viewModel.$newReleases
            .sink { [weak self] rows in
                self?.newReleasesCollectionView.reloadData()
            }
            .store(in: &cancellable)
    }
}

// MARK: - UICollectionViewDataSource
extension HomeViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.movies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(for: MovieCollectionViewCell.self, for: indexPath)
        let vm = collectionView.tag == HomeCollectionViewType.movies.rawValue
        ? viewModel.movies[indexPath.row]
        : viewModel.newReleases[indexPath.row]
        
        cell.configure(with: vm, layoutType: layoutType)
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension HomeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.selectMovie(at: indexPath.row, type: .init(rawValue: collectionView.tag))
    }
}

// MARK: - PromotionViewProtocol
extension HomeViewController: PromotionViewProtocol {
    var name: String { "HomeViewController" }
}
