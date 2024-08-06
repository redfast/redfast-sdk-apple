//
//  HomeViewModel.swift
//  Redflix
//
//  Created by Volodymyr Mykhailiuk on 07.05.2024.
//

import Combine
import Foundation

final class HomeViewModel {
    // MARK: - Properties
    @Published var movies: [MovieRowViewModel] = []
    @Published var newReleases: [MovieRowViewModel] = []
    
    private let api: RedflixAPIProtocol
    private let promotionService: PromotionServiceProtocol
    private let sdkStatusManager: SDKStatusManaging
    private let imageLoader: ImageLoaderProtocol
    private let dateFormatter: DateFormatting
    private let collectionId: String
    private var cancellable = Set<AnyCancellable>()
    weak var coordinator: TabCoordinatorProtocol?
    
    
    // MARK: - Lifecycle
    init(services: ServiceLocating, coordinator: TabCoordinatorProtocol, collectionId: String) {
        self.api = services.resolve()
        self.promotionService = services.resolve()
        self.sdkStatusManager = services.resolve()
        self.imageLoader = services.resolve()
        self.dateFormatter = services.resolve()
        self.collectionId = collectionId
        self.coordinator = coordinator
    }
    
    func setup() async throws {
        let result = try await api.fetchMovieCollection(collectionId: collectionId)
        await MainActor.run {
            let halfIndex = result.items.count / 2
            
            self.movies = result.items.prefix(upTo: halfIndex).map {
                MovieRowViewModel(
                    with: $0,
                    type: .movies,
                    imageLoader: imageLoader,
                    dateFormatter: dateFormatter
                )
            }
            self.newReleases = result.items.suffix(from: halfIndex).map {
                MovieRowViewModel(
                    with: $0,
                    type: .new,
                    imageLoader: imageLoader,
                    dateFormatter: dateFormatter
                )
            }
        }
    }
    
    func registerScreen(_ vc: PromotionViewProtocol) {
        sdkStatusManager.isSDKInitialised.sink { [weak self] isInitialised in
            if !isInitialised { return }
            self?.promotionService.setScreenName(vc) { result in
                self?.coordinator?.handlePromotion(result)
            }
        }.store(in: &cancellable)
    }
    
    func selectMovie(at index: Int, type: HomeCollectionViewType?) {
        switch type {
        case .movies:
            coordinator?.showDetails(for: movies[index])
        case .new:
            coordinator?.showDetails(for: newReleases[index])
        default:
            print("Warning: Wrong tag: \(String(describing: type?.rawValue))")
        }
    }
    
    func readMore() {
        guard let movie = (movies + newReleases).first(where: {
            $0.name.lowercased() == "silent hill"
        }) else {
            return
        }
        
        coordinator?.showDetails(for: movie )
    }
}
