//
//  MockImageLoader.swift
//  RedflixTests
//
//  Created by Volodymyr Mykhailiuk on 13.05.2024.
//

import Foundation
@testable import Redflix

final class MockImageLoader: ImageLoaderProtocol {
    enum Invocation: Equatable {
        case loadImageData
    }
    
    var invocations: [Invocation] = []
    
    var mockData = Data()
    
    func loadImageData(from url: URL) async throws -> Data {
        invocations.append(.loadImageData)
        return mockData
    }
}
