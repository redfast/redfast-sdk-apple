//
//  ContentView.swift
//  Redflix
//
//  Created by Wenwei Tao on 12/11/25.
//

import Combine
import SwiftUI
import redfast_core
import redfast_ui

struct HomeView: View {
    @StateObject var viewModel = HomeViewModel()
    @Environment(\.displayScale) private var displayScale
    @EnvironmentObject var sharedData: SharedData
    @FocusState private var focusedItemID: UUID?
    
    private let interfaceIdiom = UIDevice.current.userInterfaceIdiom
    
    private var navBarColor: Color {
        Color(hex: "#0C2737") ?? .black
    }
    
    private var bgColor: Color {
        Color(hex: "#081b27") ?? .black
    }
    
    private var moviesHeight: CGFloat {
        let scale = max(displayScale, 1)
        return (interfaceIdiom == .phone ? 386 / scale : 462) + 30
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        
#if os(iOS)
                        PromptInline(zone: "redflix-banner-phone" )
#elseif os(tvOS)
                        PromptInline(zone: "redflix-banner" )
#endif
                        
                        HeaderView(title: "Highlights today",
                                   subtitle: "Be sure not to miss these reviews today.")
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            LazyHStack(alignment: .top, spacing: 16){
                                ForEach(viewModel.movies, id: \.id) { movie in
                                    MovieItem(movie: movie, type: .standard, focusedItemID: $focusedItemID)
                                }
                            }
                            .frame(height: moviesHeight)
                            .padding()
                        }
                        
                        if let highLight = viewModel.highlightMovie {
                            MovieItem(movie: highLight, type: .highLight, focusedItemID: $focusedItemID)
                                .padding(.horizontal)
                        }
                        
                        HeaderView(title: "New Releases",
                                   subtitle: "Our most recently released reviews.")
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            LazyHStack(spacing: 10) {
                                ForEach(viewModel.releases, id: \.id) { movie in
                                    MovieItem(movie: movie, type: .release, focusedItemID: $focusedItemID)
                                }
                            }
                            .padding()
                        }
                    }
                    .padding(.vertical)
                }
                .background(bgColor)
                .navigationDestination(for: MovieData.self) { movie in
                    DetailView(movie: movie)
                }
#if os(iOS)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Image("redflix_logo")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 56)
                    }
                }
                .toolbarBackground(navBarColor, for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)
                .toolbarColorScheme(.dark, for: .navigationBar)
                .navigationBarTitleDisplayMode(.inline)
#endif
            }
        }
        .task {
            await viewModel.fetchMovies()
            sharedData.trigger = .screen("HomeViewController")
        }
    }
}

#Preview {
    HomeView()
}
