//
//  GenresViewAssembler.swift
//  Redflix
//
//  Created by Volodymyr Mykhailiuk on 21.05.2024.
//

import UIKit

enum GenresViewAssembler {
    /// Assemble and set all dependencies for `GenresViewAssembler`
    /// returns `UIViewController`
    static func assembleModule(services: ServiceLocating, coordinator: TabCoordinatorProtocol) -> UIViewController {
        let vm = GenresViewModel(services: services, coordinator: coordinator)
        let vc = GenresViewController(viewModel: vm)
        return vc
    }
}
