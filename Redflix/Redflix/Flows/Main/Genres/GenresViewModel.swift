//
//  GenresViewModel.swift
//  Redflix
//
//  Created by Volodymyr Mykhailiuk on 21.05.2024.
//

import Foundation
import RedFast
import Combine

final class GenresViewModel {
    enum SubmissionStatus {
        case none
        case bannerOfferAccepted
    }
    
    enum State {
        case none
        case loading
        case loaded([[MovieRowViewModel]])
    }
    
    private let api: RedflixAPIProtocol
    private let promotionService: PromotionServiceProtocol
    private let sdkStatusManager: SDKStatusManaging
    private let imageLoader: ImageLoaderProtocol
    private let dateFormatter: DateFormatting
    weak var coordinator: TabCoordinatorProtocol?
    
    @Published var state: State = .none
    @Published var banner: BannerRowViewModel?
    private(set) var currentBanner: Prompt?
    private(set) var movies: [[MovieRowViewModel]] = []
    
    private var cancellable = Set<AnyCancellable>()
    
    init(services: ServiceLocating, coordinator: TabCoordinatorProtocol) {
        self.api = services.resolve()
        self.promotionService = services.resolve()
        self.sdkStatusManager = services.resolve()
        self.imageLoader = services.resolve()
        self.dateFormatter = services.resolve()
        self.coordinator = coordinator
    }
    
    func setup() async throws {
        await MainActor.run {
            state = .loading
        }
        
        let result = try await api.fetchMovieCollection(collectionId: AppConstants.collectionId)
        let viewModels = result.items.map {
            MovieRowViewModel(
                with: $0,
                type: .movies,
                imageLoader: imageLoader,
                dateFormatter: dateFormatter
            )
        }
        let sortedMovies = Dictionary(grouping: viewModels) {
            $0.category
        }.map {
            $0.value
        }.filter{
            !$0.isEmpty
        }.sorted {
            if $0.count == $1.count {
                return $0.first!.category.name < $1.first!.category.name
            }
            return $0.count > $1.count
        }

        await MainActor.run {
            self.movies = sortedMovies
            self.state = .loaded(sortedMovies)
        }
    }
    
    func registerScreen(for vc: PromotionViewProtocol, type: InlineType) {
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
    
    func selectMovie(at section: Int, row: Int) {
        guard case .loaded(let movies) = state else {
            return
        }

        coordinator?.showDetails(for: movies[section][row])
    }
    
    func selectBanner(at index: Int) async throws {
        guard
            let prompt = currentBanner,
            let sku = prompt.properties.appleInappProductId
        else {
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
