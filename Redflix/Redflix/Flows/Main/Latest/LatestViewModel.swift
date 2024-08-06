//
//  LatestViewModel.swift
//  Redflix
//
//  Created by Volodymyr Mykhailiuk on 14.05.2024.
//

import Foundation
import Combine
import RedFast

final class LatestViewModel {
    
    enum State {
        case none
        case loading
        case loaded([MovieRowViewModel])
    }
    
    // MARK: - Properties
    private let api: RedflixAPIProtocol
    private let promotionService: PromotionServiceProtocol
    private let sdkStatusManager: SDKStatusManaging
    private let imageLoader: ImageLoaderProtocol
    private let dateFormatter: DateFormatting
    weak var coordinator: TabCoordinatorProtocol?
    private let collectionId: String
    private var cancellable = Set<AnyCancellable>()
    
    @Published var state: State = .none
    @Published var banner: BannerRowViewModel?
    private(set) var currentBanner: Prompt?
    private(set) var latestMovies: [MovieRowViewModel] = []
    
    // MARK: - Lifecycle
    init(services: ServiceLocating, coordinator: TabCoordinatorProtocol, collectionId: String) {
        self.api = services.resolve()
        self.promotionService = services.resolve()
        self.sdkStatusManager = services.resolve()
        self.imageLoader = services.resolve()
        self.dateFormatter = services.resolve()
        self.coordinator = coordinator
        self.collectionId = collectionId
    }
    
    func setup() async throws {
        state = .loading
        let result = try await api.fetchMovieCollection(collectionId: collectionId)
        await MainActor.run {
            self.latestMovies = result.items.map {
                MovieRowViewModel(
                    with: $0,
                    type: .movies,
                    imageLoader: imageLoader,
                    dateFormatter: dateFormatter
                )
            }.sorted {
                $0.name.lowercased() < $1.name.lowercased()
            }
            state = .loaded(latestMovies)
        }
    }
    
    func registerScreen(_ vc: PromotionViewProtocol, type: InlineType) {
        sdkStatusManager.isSDKInitialised.sink { [weak self] isInitialised in
            guard let self, isInitialised else { return }
            self.promotionService.setScreenName(vc) { result in
                self.coordinator?.handlePromotion(result)
            }
            let inlineBanner = self.promotionService.getInlines(type).first
            self.currentBanner = inlineBanner
            self.banner = BannerRowViewModel(prompt: inlineBanner, imageLoader: self.imageLoader)
        }.store(in: &cancellable)
    }
    
    func selectMovie(at index: Int) {
        switch state {
        case .loaded(let latestMovies):
            coordinator?.showDetails(for: latestMovies[index])
        default:
            break
        }
    }
    
    func selectBanner() async throws {
        guard let prompt = currentBanner, let sku = prompt.properties.appleInappProductId else {
            return
        }
        
        coordinator?.showLoading(true, completion: nil)
        try await coordinator?.startPurchase(sku: sku)
        promotionService.onInlineClick(prompt: prompt) { _ in }
        coordinator?.showLoading(false, completion: nil)
    }
    
    func showLoading(_ isLoading: Bool, completion: (() -> Void)? = nil) {
        coordinator?.showLoading(isLoading, completion: completion)
    }
}
