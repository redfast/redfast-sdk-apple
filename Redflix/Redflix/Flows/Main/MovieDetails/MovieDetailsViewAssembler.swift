//
//  MovieDetailsViewAssembler.swift
//  Redflix
//
//  Created by Volodymyr Mykhailiuk on 16.05.2024.
//

import UIKit

enum MovieDetailsViewAssembler {
    /// Assemble and set all dependencies for `MovieDetailsViewAssembler`
    /// returns `UIViewController`
    static func assembleModule(
        services: ServiceLocating,
        coordinator: TabCoordinatorProtocol,
        rowViewModel: MovieRowViewModel
    ) -> UIViewController {
        let vm = MovieDetailsViewModel(
            services: services,
            coordinator: coordinator,
            rowViewModel: rowViewModel
        )
        let vc = MovieDetailsViewController(viewModel: vm)
        return vc
    }
}
