//
//  BaseViewModel.swift
//  Redflix
//
//  Created by sbonilla on 23/12/25.
//

import SwiftUI

class BaseViewModel {
    let networkManager: NetworkManager = NetworkManager()
    let baseURL = "https://api.webflow.com/v2/"
    let headers = [ "Accept": "application/json",
                    "accept-version": "1.0.0",
                    "Authorization": "Bearer \(AppConstants.webflowBearerToken)"]
}
