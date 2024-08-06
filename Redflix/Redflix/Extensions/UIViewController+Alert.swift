//
//  UIViewController+Alert.swift
//  Redflix
//
//  Created by Volodymyr Mykhailiuk on 27.05.2024.
//

import UIKit

extension UIViewController {
    func showAlertMessage(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okButton = UIAlertAction(title: "OK", style: .default)
        
        alert.addAction(okButton)
        present(alert, animated: true)
    }
}
