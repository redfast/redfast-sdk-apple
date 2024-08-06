//
//  GenresViewController.swift
//  Redflix
//
//  Created by Volodymyr Mykhailiuk on 21.05.2024.
//

import UIKit
import Combine

final class GenresViewController: UIViewController {
    
    enum Constants {
        static let alertTitle = "Congratulations!"
        static let alertMessage = "You've unlocked a 50% discount on the annual plan!"
    }
    
    // MARK: - Properties
    private let viewModel: GenresViewModel
    private var cancellable = Set<AnyCancellable>()
    
    private var isLoaded = false
    private let bannerPositionIndex = 1
    private var layoutType: LayoutType {
        UIDevice.current.userInterfaceIdiom == .phone ? .phone : .landscape
    }
    
    private var collectionInsets: CGFloat {
        layoutType == .phone ? 8 : 16
    }
    
    private var bannerType: InlineType {
        UIDevice.current.userInterfaceIdiom == .phone ? .redflixBannerPhone : .redflixBanner
    }
    
    private var collectionItemSize: CGSize {
        let moviesWidth = min(UIScreen.main.bounds.width / 2 - collectionInsets * 2, 270)
        let moviesHeight = min(max(moviesWidth / 0.57, 200), 462)
        return CGSize(width: moviesWidth, height: moviesHeight)
    }
    
    // MARK: - Subviews
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: .init())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.contentInset = .init(top: layoutType == .phone ? 16 : 24, left: 0, bottom: 0, right: 0)
        collectionView.register(cell: MovieCollectionViewCell.self)
        collectionView.register(cell: BannerCollectionViewCell.self)
        collectionView.register(
            header: CollectionHeaderView.self,
            kind: CollectionHeaderView.supplementaryViewKind
        )
        let layout = UICollectionViewCompositionalLayout { _, _ in    
            CollectionLayoutSection.moviesLayout(
                collectionItemSize: self.collectionItemSize,
                collectionInsets: self.collectionInsets,
                layoutType: self.layoutType
            )
        }
        collectionView.setCollectionViewLayout(layout, animated: true)
        return collectionView
    }()
    
    // MARK: - Lifecycle
    init(viewModel: GenresViewModel) {
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
            try? await viewModel.setup()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if isLoaded {
            viewModel.registerScreen(for: self, type: bannerType)
        }
    }
    
    private func adjustedSection(_ section: Int) -> Int {
        if viewModel.banner == nil {
            return section
        }
        
        return section > bannerPositionIndex ? section - 1 : section
    }
}

// MARK: - Configurations
extension GenresViewController {
    func setupViewHierarchy() {
        view.addSubview(collectionView)
    }
    
    func setupConstraints() {
        view.addAnchorConstraintsTo(view: collectionView, constraints: .init(all: 0))
    }
    
    func setupAppearance() {
        navigationItem.applyBrandNavigationTitle()
        view.backgroundColor = AppColor.contentBGColor
        collectionView.backgroundColor = .clear
    }
    
    func setupBindings() {
        viewModel.$state
            .sink { [weak self] state in
                guard let self else { return }
                DispatchQueue.main.async {
                    switch state {
                    case .loaded:
                        self.viewModel.showLoading(false) {
                            self.viewModel.registerScreen(for: self, type: self.bannerType)
                            self.isLoaded = true
                        }
                        self.collectionView.reloadData()
                    case .loading:
                        self.viewModel.showLoading(true)
                    default:
                        break
                    }
                }
            }
            .store(in: &cancellable)
        
        viewModel.$banner
            .sink { [weak self] banner in
                DispatchQueue.main.async {
                    guard let self else { return }
                    let layout = UICollectionViewCompositionalLayout { sectionIndex, _ in
                        if let banner, sectionIndex == self.bannerPositionIndex {
                            CollectionLayoutSection.bannerLayout(
                                collectionInsets: self.collectionInsets,
                                aspectRatio: banner.aspectRatio ?? 0.2
                            )
                        } else {
                            CollectionLayoutSection.moviesLayout(
                                collectionItemSize: self.collectionItemSize,
                                collectionInsets: self.collectionInsets,
                                layoutType: self.layoutType
                            )
                        }
                    }
                    self.collectionView.setCollectionViewLayout(layout, animated: true)
                    if case .loaded = self.viewModel.state {
                        self.collectionView.reloadSections(IndexSet(integer: self.bannerPositionIndex))
                    }
                }
            }
            .store(in: &cancellable)
    }
}

// MARK: - UICollectionViewDelegate
extension GenresViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if viewModel.banner != nil && indexPath.section == bannerPositionIndex {
            Task {
                try? await viewModel.selectBanner(at: indexPath.section)
            }
            return
        }
        let adjustedSection = adjustedSection(indexPath.section)
        viewModel.selectMovie(at: adjustedSection, row: indexPath.row)
    }
}

// MARK: - UICollectionViewDataSource
extension GenresViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        guard case .loaded(let movies) = viewModel.state else {
            return 0
        }
        if viewModel.banner != nil {
            return movies.count + 1
        }
        return movies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard case .loaded(let movies) = viewModel.state else {
            return 0
        }
        if section == bannerPositionIndex && viewModel.banner != nil {
            return 1
        }
        let adjustedSection = adjustedSection(section)
        return movies[adjustedSection].count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard case .loaded(let movies) = viewModel.state else {
            return .init()
        }
        if let banner = viewModel.banner, indexPath.section == bannerPositionIndex {
            let cell = collectionView.dequeueReusableCell(for: BannerCollectionViewCell.self, for: indexPath)
            cell.configure(with: banner)
            return cell
        }
        let cell = collectionView.dequeueReusableCell(for: MovieCollectionViewCell.self, for: indexPath)
        let adjustedSection = adjustedSection(indexPath.section)
        let vm = movies[adjustedSection][indexPath.row]
        cell.configure(with: vm, layoutType: layoutType)
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension GenresViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableHeader(
            for: CollectionHeaderView.self,
            for: indexPath,
            kind: CollectionHeaderView.supplementaryViewKind
        )
        guard case .loaded(let movies) = viewModel.state, !movies.isEmpty else {
            return header
        }
        let adjustedSection = adjustedSection(indexPath.section)
        let categoryName = movies[adjustedSection][indexPath.row].category.name
        header.configure(
            withFont: .custom(
                type: .catamaranExtraBold, ofSize: layoutType == .phone ? 18 : 36
            )
        )
        header.configure(withText: categoryName)

        return header
    }
}

// MARK: - PromotionViewProtocol
extension GenresViewController: PromotionViewProtocol {
    var name: String { "GenresViewController" }
}
