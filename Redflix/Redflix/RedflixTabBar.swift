//
//  RedflixTabBar.swift
//  Redflix
//
//  Created by sbonilla on 22/12/25.
//

import SwiftUI
import Combine
import redfast_ui

struct RedflixTabBar: View {
    @StateObject var sharedData = SharedData()
    
    var body: some View {
        TabView {
            HomeView()
                .environmentObject(sharedData)
                .tabItem {
                    Label("Home", image: "home")
                }
            LatestView()
                .environmentObject(sharedData)
                .tabItem {
                    Label("Latest", image: "latest")
                }
            HomeView()
                .environmentObject(sharedData)
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
        .tint(.white)
        .promptOverlay(trigger: $sharedData.trigger) { result in
            _ = result
        }
    }
}

class SharedData: ObservableObject {
    @Published var trigger: PromptOverlayTrigger?
}
