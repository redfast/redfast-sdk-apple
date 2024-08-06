//
//  LatestViewAssembler.swift
//  Redflix
//
//  Created by Volodymyr Mykhailiuk on 14.05.2024.
//

import UIKit

enum LatestViewAssembler {
    /// Assemble and set all dependencies for `LatestViewAssembler`
    /// returns `UIViewController`
    static func assembleModule(services: ServiceLocating, coordinator: TabCoordinatorProtocol) -> UIViewController {
        let vm = LatestViewModel(
            services: services,
            coordinator: coordinator,
            collectionId: AppConstants.collectionId
        )
        let vc = LatestViewController(viewModel: vm)
        return vc
    }
}
