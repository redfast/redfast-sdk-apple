//
//  ProfileViewAssembler.swift
//  Redflix
//
//  Created by Volodymyr Mykhailiuk on 23.05.2024.
//

import UIKit

enum ProfileViewAssembler {
    /// Assemble and set all dependencies for `ProfileViewAssembler`
    /// returns `UIViewController`
    static func assembleModule(services: ServiceLocating, coordinator: TabCoordinatorProtocol) -> UIViewController {
        let vm = ProfileViewModel(services: services, coordinator: coordinator)
        let vc = ProfileViewController(viewModel: vm)
        return vc
    }
}
