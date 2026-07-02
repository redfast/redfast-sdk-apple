//
//  Extension.swift
//  Redflix
//
//  Created by sbonilla on 23/12/25.
//

import SwiftUI

extension Color {
    init?(hex: String) {
        if hex.hasPrefix("#") {
            let start = hex.index(hex.startIndex, offsetBy: 1)
            var hexColor = String(hex[start...])
            
            if hexColor.count == 6 {
                hexColor.append("FF")
            }
            
            let scanner = Scanner(string: hexColor)
            var hexNumber: UInt64 = 0
            if  scanner.scanHexInt64(&hexNumber) {
                let r = CGFloat((hexNumber >> 24) & 0xff) / 255
                let g = CGFloat((hexNumber >> 16) & 0xff) / 255
                let b = CGFloat((hexNumber >> 08) & 0xff) / 255
                let a = CGFloat((hexNumber >> 00) & 0xff) / 255
                
                self.init(.sRGB,
                          red: r,
                          green: g,
                          blue: b,
                          opacity: a)
                return
            }
        }
        return nil
    }
}
