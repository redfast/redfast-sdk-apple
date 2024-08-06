//
//  EmailValidator.swift
//  Redflix
//
//  Created by Volodymyr Mykhailiuk on 27.05.2024.
//

import Foundation

protocol EmailValidatorProtocol {
    func isValidEmail(_ email: String?) -> Bool
}

final class EmailValidator: EmailValidatorProtocol {
    func isValidEmail(_ email: String?) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPredicate.evaluate(with: email)
    }
}
