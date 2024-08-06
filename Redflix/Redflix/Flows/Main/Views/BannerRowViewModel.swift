//
//  BannerRowViewModel.swift
//  Redflix
//
//  Created by Volodymyr Mykhailiuk on 29.05.2024.
//

import Foundation
import RedFast

final class BannerRowViewModel {
    private let imageLoader: ImageLoaderProtocol
    let imageURL: URL
    let aspectRatio: CGFloat?
    
    init?(prompt: Prompt?, imageLoader: ImageLoaderProtocol) {
        guard let prompt,
              let compositeBgImage = prompt.compositeBgImage,
              let url = URL(string: compositeBgImage) else
        {
            return nil
        }
        self.imageLoader = imageLoader
        self.imageURL = url
        self.aspectRatio = prompt.tileAspectRatio
    }
    
    func loadImageData() async -> Data? {
        return try? await imageLoader.loadImageData(from: imageURL)
    }
}
