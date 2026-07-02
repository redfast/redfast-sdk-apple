//
//  HeaderView.swift
//  Redflix
//
//  Created by sbonilla on 23/12/25.
//

import SwiftUI

struct HeaderView: View {
    var title: String
    var subtitle: String
    
    private let interfaceIdiom = UIDevice.current.userInterfaceIdiom
    private var titleFontSize: CGFloat {
        switch interfaceIdiom {
        case .phone:
            return 28
        default:
            return 42
        }
    }
    private var subtitleFontSize: CGFloat {
        switch interfaceIdiom {
        case .phone:
            return 12
        default:
            return 18
        }
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            Text(title)
                .font(Font.system(size: titleFontSize, weight: .bold))
                .foregroundColor(.white)
            Text(subtitle)
                .font(Font.system(size: subtitleFontSize, weight: .regular))
                .foregroundColor(.white)
        }
        .padding(.vertical, 8)
    }
}
