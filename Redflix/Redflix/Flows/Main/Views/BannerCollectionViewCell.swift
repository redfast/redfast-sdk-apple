//
//  BannerCollectionViewCell.swift
//  Redflix
//
//  Created by Volodymyr Mykhailiuk on 29.05.2024.
//

import UIKit

final class BannerCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Subviews
    private lazy var bannerView: BannerView = {
        let view = BannerView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
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
    func configure(with vm: BannerRowViewModel) {
        Task {
            guard let imageData = await vm.loadImageData() else {
                return
            }
            await MainActor.run {
                bannerView.configure(with: UIImage(data: imageData))
            }
        }
    }
}

// MARK: - Configurations
private extension BannerCollectionViewCell {
    func setupViewHierarchy() {
        contentView.addSubview(bannerView)
    }
    
    func setupConstraints() {
        addAnchorConstraintsTo(view: contentView, constraints: .init(all: 0))
        bannerView.addAnchorConstraintsTo(view: contentView, constraints: .init(all: 0))
    }
}
