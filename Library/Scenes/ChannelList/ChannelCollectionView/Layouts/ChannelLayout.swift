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
    
    let maxHeaderHeight: CGFloat = 100
    let minHeaderHeight: CGFloat = 40
    
    let layoutMargin = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    var layoutAttributes = [IndexPath: UICollectionViewLayoutAttributes]()
    
    var headerAttributes: UICollectionViewLayoutAttributes?
    
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
        
        prepareHeaderLayoutAttribute()
    }
    
    func configure(attributes: UICollectionViewLayoutAttributes, for index: Int, of count: Int, in collectionView: UICollectionView) {
        fatalError("configure not implemented")
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var attributes = layoutAttributes.values.filter({ rect.intersects($0.frame) })
        if let headerAttributes = headerAttributes {
            attributes.append(headerAttributes)
        }
        return attributes
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
    
    // MARK: - Header
    
    var headerHeight: CGFloat {
        return overwriteHeaderHeight ?? max(min(maxHeaderHeight, maxHeaderHeight - contentOffset.y), minHeaderHeight)
    }
    
    private func prepareHeaderLayoutAttribute() {
        guard let collectionView = collectionView else { return }
        let attributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: HeaderCollectionReusableView.kind, with: IndexPath(item: 0, section: 0))
        
        attributes.frame = CGRect(x: 0, y: contentOffset.y, width: collectionView.bounds.width, height: headerHeight)
        attributes.zIndex = -100
        
        if self is ExposedLayout {
            attributes.alpha = 0
            attributes.isHidden = true
            attributes.frame.origin.y = 0
        }
        
        headerAttributes = attributes
    }
    
    override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return headerAttributes
    }
}
