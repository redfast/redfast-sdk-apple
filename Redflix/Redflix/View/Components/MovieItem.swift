//
//  MovieItem.swift
//  Redflix
//
//  Created by sbonilla on 23/12/25.
//

import SwiftUI

struct MovieItem: View {
    
    enum MovieItemType {
        case standard
        case highLight
        case release
    }
    
    @Environment(\.displayScale) private var displayScale
    private let interfaceIdiom = UIDevice.current.userInterfaceIdiom
    private var scale: CGFloat {
        max(displayScale, 1)
    }
    
    let movie: MovieData
    let type: MovieItemType

    var focusedItemID: FocusState<UUID?>.Binding
    
    private var width: CGFloat {
        switch type {
        case .standard:
            return interfaceIdiom == .phone ? 290/scale : 270
        case .highLight:
            return UIScreen.main.bounds.width
        case .release:
            return interfaceIdiom == .phone ? 440/scale : 480
        }
    }
    
    private var height: CGFloat {
        switch type {
        case .standard:
            return interfaceIdiom == .phone ? 386/scale : 462
        case .highLight:
            return interfaceIdiom == .phone ? 400 : 500
        case .release:
            return interfaceIdiom == .phone ? 248/scale : 342
        }
    }
    
    private var fontSize: CGFloat {
        switch type {
        case .standard, .release:
            return interfaceIdiom == .phone ? 12 : 14
        case .highLight:
            return interfaceIdiom == .phone ? 28 : 52
        }
    }
    
    private var isFocused: Bool {
        focusedItemID.wrappedValue == movie.id
    }
    
    var body: some View {
        NavigationLink(value: movie) {
            Group {
                if type == .highLight {
                    ZStack(alignment: .bottom) {
                        movieImage
                        movieTitle
                    }
                    .frame(height: height)
                } else {
                    VStack(alignment: .leading, spacing: 8) {
                        movieImage
                        movieTitle
                    }
                    .frame(maxWidth: width)
                }
            }
            .scaleEffect(isFocused ? 1.08 : 1.0)
            .shadow(color: isFocused ? Color.white.opacity(0.6) : .clear, radius: 12)
            .animation(.snappy(duration: 0.2), value: isFocused)
        }
        .buttonStyle(.plain)
        .focused(focusedItemID, equals: movie.id)
        .focusEffectDisabled()
        .hoverEffectDisabled()
    }
    
    @ViewBuilder
    var movieImage: some View {
        AsyncImage(url: type == .standard ? movie.portraitURL : movie.landscapeURL) { phase in
            if let image = phase.image {
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: width, height: height)
                    .clipped()
            } else {
                ProgressView()
                    .frame(width: width, height: height)
            }
        }
    }
    
    @ViewBuilder
    var movieTitle: some View {
        Text(movie.name ?? "")
            .font(.system(size: fontSize, weight: .bold))
            .foregroundColor(.white)
            .lineLimit(1)
            .fixedSize(horizontal: false, vertical: true)
            .frame(width: width, alignment: .center)
            .background(type == .highLight ? Color.black.opacity(0.6) : Color.clear)
    }
}
