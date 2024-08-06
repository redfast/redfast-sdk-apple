//
//  LatestViewController.swift
//  Redflix
//
//  Created by Volodymyr Mykhailiuk on 14.05.2024.
//

import UIKit
import Combine

final class LatestViewController: UIViewController {
    enum Constants {
        static let bgColor = AppColor.contentBGColor
        static let alertTitle = "Congratulations!"
        static let alertMessage = "You've unlocked a 50% discount on the annual plan!"
    }
    
    // MARK: - Properties
    private var cancellable = Set<AnyCancellable>()
    private let viewModel: LatestViewModel
    private var isLoaded = false
    
    private var layoutType: LayoutType {
        UIDevice.current.userInterfaceIdiom == .phone ? .phone : .landscape
    }
    
    private var collectionInsets: CGFloat {
        layoutType == .phone ? 8 : 16
    }
    
    private var collectionItemSize: CGSize {
        let moviesWidth = min(UIScreen.main.bounds.width / 2 - collectionInsets * 2, 270)
        let moviesHeight = min(max(moviesWidth / 0.57, 200), 462)
        return CGSize(width: moviesWidth, height: moviesHeight)
    }
    
    private var bannerType: InlineType {
        UIDevice.current.userInterfaceIdiom == .phone ? .redflixBannerPhone : .redflixBanner
    }
    
    // MARK: - Subviews
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = collectionItemSize
        layout.sectionInset = UIEdgeInsets(horizontal: 0, vertical: collectionInsets)
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = collectionInsets
        layout.minimumInteritemSpacing = collectionInsets
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.contentInset = .init(all: collectionInsets)
        collectionView.register(cell: MovieCollectionViewCell.self)
        collectionView.register(
            header: BannerCollectionReusableView.self,
            kind: UICollectionView.elementKindSectionHeader
        )
        return collectionView
    }()
    
    // MARK: - Lifecycle
    init(viewModel: LatestViewModel) {
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
            viewModel.registerScreen(self, type: bannerType)
        }
    }
}

// MARK: - Configurations
extension LatestViewController {
    func setupViewHierarchy() {
        view.addSubview(collectionView)
    }
    
    func setupConstraints() {
        view.addAnchorConstraintsTo(view: collectionView, constraints: .init(all: 0))
    }
    
    func setupAppearance() {
        navigationItem.applyBrandNavigationTitle()
        view.backgroundColor = Constants.bgColor
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
                            self.viewModel.registerScreen(self, type: self.bannerType)
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
            .sink { [weak self] _ in
                DispatchQueue.main.async {
                    self?.collectionView.reloadData()
                }
            }
            .store(in: &cancellable)
    }
}

// MARK: - UICollectionViewDelegate
extension LatestViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.selectMovie(at: indexPath.row)
    }
}

// MARK: - UICollectionViewDataSource
extension LatestViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard case .loaded(let latestMovies) = viewModel.state else {
            return 0
        }
        return latestMovies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard case .loaded(let latestMovies) = viewModel.state else {
            return .init()
        }
        let cell = collectionView.dequeueReusableCell(for: MovieCollectionViewCell.self, for: indexPath)
        let vm = latestMovies[indexPath.row]
        cell.configure(with: vm, layoutType: layoutType)
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension LatestViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableHeader(
            for: BannerCollectionReusableView.self,
            for: indexPath,
            kind: UICollectionView.elementKindSectionHeader
        )
        if let banner = viewModel.banner {
            header.configure(with: banner)
            header.onSelectBanner = { [weak self] in
                Task {
                    do {
                        try await self?.viewModel.selectBanner()
                    } catch {
                        print("IAP error: \(error.localizedDescription)")
                    }
                }
            }
            header.isHidden = false
        } else {
            header.isHidden = true
        }
        
        return header
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        guard let aspectRatio = viewModel.banner?.aspectRatio else {
            return .zero
        }
        let width = collectionView.frame.width - collectionInsets * 2
        let height = width * aspectRatio
        return CGSize(width: width, height: height)
    }
}

// MARK: - PromotionViewProtocol
extension LatestViewController: PromotionViewProtocol {
    var name: String { "LatestViewController" }
}
