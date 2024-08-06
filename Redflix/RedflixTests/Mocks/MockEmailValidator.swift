//
//  MockEmailValidator.swift
//  RedflixTests
//
//  Created by Volodymyr Mykhailiuk on 27.05.2024.
//

import Foundation
@testable import Redflix

final class MockEmailValidator: EmailValidatorProtocol {
    var isValidEmailResult: Bool = true
    
    func isValidEmail(_ email: String?) -> Bool {
        return isValidEmailResult
    }
}
