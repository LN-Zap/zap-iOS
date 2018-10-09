//
//  ChannelLayout.swift
//  ChannelViewTest
//
//  Created by Otto Suess on 27.07.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import UIKit

protocol ChannelListDataSource: UICollectionViewDataSource {
    func heightForItem(at index: Int) -> CGFloat
}

class ChannelLayout: UICollectionViewLayout {
    var overwriteContentOffset: CGPoint?
    var overwriteHeaderHeight: CGFloat?
    
    let layoutMargin = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    var layoutAttributes = [IndexPath: UICollectionViewLayoutAttributes]()
    
    var contentOffset: CGPoint {
        return overwriteContentOffset ?? collectionView?.contentOffset ?? CGPoint.zero
    }
    
    override func prepare() {
        guard let collectionView = collectionView else { return }
        
        let itemCount = collectionView.numberOfItems(inSection: 0)
        
        var layoutAttributes = [IndexPath: UICollectionViewLayoutAttributes]()
        for index in 0..<itemCount {
            let indexPath = IndexPath(item: index, section: 0)
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            configure(attributes: attributes, for: index, of: itemCount, in: collectionView)
            layoutAttributes[indexPath] = attributes
        }
        
        self.layoutAttributes = layoutAttributes
    }
    
    func configure(attributes: UICollectionViewLayoutAttributes, for index: Int, of count: Int, in collectionView: UICollectionView) {
        fatalError("configure not implemented")
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return layoutAttributes.values.filter({ rect.intersects($0.frame) })
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return layoutAttributes[indexPath]
    }
    
    func heightForItem(at index: Int) -> CGFloat {
        if let dataSource = self.collectionView?.dataSource as? ChannelListDataSource {
            return dataSource.heightForItem(at: index)
        }
        return 360
    }
}
