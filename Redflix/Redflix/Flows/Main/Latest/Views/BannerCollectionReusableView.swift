//
//  BannerCollectionReusableView.swift
//  Redflix
//
//  Created by Volodymyr Mykhailiuk on 30.05.2024.
//

import UIKit

final class BannerCollectionReusableView: UICollectionReusableView {
    
    // MARK: - Properties
    override var canBecomeFocused: Bool {
        true
    }
    
    private lazy var tapRecognizer: UITapGestureRecognizer = {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped))
#if os(tvOS)
        tapRecognizer.allowedPressTypes = [NSNumber(value: UIPress.PressType.select.rawValue)]
#endif
        return tapRecognizer
    }()
    
    var onSelectBanner: (() -> Void)?
    
    // MARK: - Subviews
    private lazy var bannerView: BannerView = {
        let view = BannerView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
#if os(tvOS)
        view.clipsToBounds = false
#endif
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
            let data = await vm.loadImageData()
            if let data, let image = UIImage(data: data) {
                await MainActor.run {
                    bannerView.configure(with: image)
                }
            }
        }
    }
    
    // MARK: - Private
    private func setupViewHierarchy() {
        addSubview(bannerView)
        addGestureRecognizer(tapRecognizer)
    }
    
    private func setupConstraints() {
        addAnchorConstraintsTo(view: bannerView, constraints: .init(all: 0))
    }
    
    // MARK: - Actions
    @objc private func tapped() {
        onSelectBanner?()
    }
}
