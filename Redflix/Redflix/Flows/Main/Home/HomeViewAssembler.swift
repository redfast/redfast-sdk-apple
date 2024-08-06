//
//  HomeViewAssembler.swift
//  Redflix
//
//  Created by Volodymyr Mykhailiuk on 07.05.2024.
//

import UIKit

enum HomeViewAssembler {
    /// Assemble and set all dependencies for `HomeViewAssembler`
    /// returns `UIViewController`
    static func assembleModule(services: ServiceLocating, coordinator: TabCoordinatorProtocol) -> UIViewController {
        let vm = HomeViewModel(
            services: services,
            coordinator: coordinator,
            collectionId: AppConstants.collectionId
        )
        let vc = HomeViewController(viewModel: vm)
        return vc
    }
}
