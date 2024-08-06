//
//  CollectionLayoutSection.swift
//  Redflix
//
//  Created by Volodymyr Mykhailiuk on 30.05.2024.
//

import UIKit

enum CollectionLayoutSection {
    static func moviesLayout(
        collectionItemSize: CGSize,
        collectionInsets: CGFloat,
        layoutType: LayoutType
    ) -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(
            layoutSize: .init(
                widthDimension: .fractionalWidth(1),
                heightDimension: .fractionalHeight(1)
            )
        )

        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: .init(
                widthDimension: .absolute(collectionItemSize.width),
                heightDimension: .absolute(collectionItemSize.height)
            ),
            subitems: [item]
        )
        group.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: collectionInsets)
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 15, bottom: layoutType == .phone ? 20 : 40, trailing: 0)
        section.orthogonalScrollingBehavior = .continuous
        
        section.boundarySupplementaryItems = [
            .init(
                layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(30)),
                elementKind: CollectionHeaderView.supplementaryViewKind,
                alignment: .top
            )
        ]
        
        return section
    }
    
    static func bannerLayout(collectionInsets: CGFloat, aspectRatio: CGFloat) -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(
            layoutSize: .init(
                widthDimension: .fractionalWidth(1),
                heightDimension: .fractionalHeight(1)
            )
        )

        let aspectRatio: CGFloat = aspectRatio
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: .init(
                widthDimension: .fractionalWidth(1),
                heightDimension: .fractionalWidth(aspectRatio)
            ),
            subitems: [item]
        )
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: collectionInsets, bottom: collectionInsets * 2, trailing: collectionInsets)
        
        return section
    }
}
