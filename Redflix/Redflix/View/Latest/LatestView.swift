//
//  LatestView.swift
//  Redflix
//

import SwiftUI
import redfast_core
import redfast_ui

struct LatestView: View {
    @EnvironmentObject var sharedData: SharedData
    @StateObject var viewModel = LatestViewModel()
    @FocusState private var focusedItemID: UUID?

    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    private var bgColor: Color {
        Color(hex: "#081b27") ?? .black
    }

    private var navBarColor: Color {
        Color(hex: "#0C2737") ?? .black
    }

    var body: some View {
        NavigationStack {
            ZStack {
                content
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
            let prompts = PromptManager.shared.getTriggerablePrompts(
                screenName: "latest",
                type: .MODAL
            )
            sharedData.trigger = .prompt(prompts.first)
        }
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading {
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if let error = viewModel.error {
            Text(error)
                .foregroundColor(.red)
                .multilineTextAlignment(.center)
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            ScrollView(showsIndicators: false) {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(viewModel.movies, id: \.id) { movie in
                        MovieItem(movie: movie, type: .standard, focusedItemID: $focusedItemID)
                    }
                }
                .padding(16)
            }
        }
    }
}

#Preview {
    LatestView()
}
