//
//  UICollectionView+Tools.swift
//  Redflix
//
//  Created by Volodymyr Mykhailiuk on 14.05.2024.
//

import UIKit

extension UICollectionView {
    private func reuseIdentifier<T>(for type: T.Type) -> String {
        return String(describing: type)
    }

    public func register<T: UICollectionViewCell>(cell: T.Type) {
        register(T.self, forCellWithReuseIdentifier: reuseIdentifier(for: cell))
    }

    public func dequeueReusableCell<T: UICollectionViewCell>(for type: T.Type, for indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withReuseIdentifier: reuseIdentifier(for: type), for: indexPath) as? T else {
            preconditionFailure("Failed to dequeue cell.")
        }

        return cell
    }
    
    public func register<T: UICollectionReusableView>(header: T.Type, kind: String) {
        let reuseId = reuseIdentifier(for: header)
        register(T.self, forSupplementaryViewOfKind: kind, withReuseIdentifier: reuseId)
    }
    
    public func dequeueReusableHeader<T: UICollectionReusableView>(for type: T.Type, for indexPath: IndexPath, kind: String) -> T {
        let reuseId = reuseIdentifier(for: type)
        guard let header = dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: reuseId,
            for: indexPath
        ) as? T else {
            preconditionFailure("Failed to dequeue supplementary view.")
        }
        return header
    }
}
