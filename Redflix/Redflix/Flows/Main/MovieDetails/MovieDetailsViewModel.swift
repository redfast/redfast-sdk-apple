//
//  MovieDetailsViewModel.swift
//  Redflix
//
//  Created by Volodymyr Mykhailiuk on 16.05.2024.
//

import Foundation
import Combine

final class MovieDetailsViewModel {
    // MARK: - Services
    private let rowViewModel: MovieRowViewModel
    private let imageLoader: ImageLoaderProtocol
    private let sdkStatusManager: SDKStatusManaging
    private let promotionService: PromotionServiceProtocol
    weak var coordinator: TabCoordinatorProtocol?
    
    // MARK: - Properties
    @Published var imageData: Data? = nil
    @Published var landscapeImageData: Data? = nil
    @Published var movieName: String = ""
    @Published var ratingString: String = ""
    @Published var category: String = ""
    @Published var releaseDate: String = ""
    @Published var movieStarRating: Int?
    @Published var movieDescription: String = ""
    @Published var duration: String = ""
    @Published var director: String = ""
    private var cancellable = Set<AnyCancellable>()
    
    init(
        services: ServiceLocating,
        coordinator: TabCoordinatorProtocol,
        rowViewModel: MovieRowViewModel
    ) {
        self.rowViewModel = rowViewModel
        self.imageLoader = services.resolve()
        self.sdkStatusManager = services.resolve()
        self.promotionService = services.resolve()
        self.coordinator = coordinator
    }
    
    func setup() async {
        await MainActor.run {
            movieName = rowViewModel.name
            ratingString = String(rowViewModel.rating)
            category = rowViewModel.category.name
            releaseDate = rowViewModel.releaseDate ?? ""
            movieStarRating = rowViewModel.starRating
            movieDescription = rowViewModel.shortDescription
            duration = rowViewModel.duration
            director = rowViewModel.director
        }
        
        guard let portraitImageURL = rowViewModel.portraitImageURL else {
            return
        }
        let portraitImageData = try? await imageLoader.loadImageData(from: portraitImageURL)
        await MainActor.run {
            self.imageData = portraitImageData
        }
        
        guard let landscapeImageURL = rowViewModel.landscapeImageURL else {
            return
        }
        let landscapeImageData = try? await imageLoader.loadImageData(from: landscapeImageURL)
        await MainActor.run {
            self.landscapeImageData = landscapeImageData
        }
    }
    
    func registerScreen(_ vc: PromotionViewProtocol) {
        sdkStatusManager.isSDKInitialised.sink { [weak self] isInitialised in
            if !isInitialised { return }
            self?.promotionService.setScreenName(vc) {
                self?.coordinator?.handlePromotion($0)
            }
        }.store(in: &cancellable)
    }
}
