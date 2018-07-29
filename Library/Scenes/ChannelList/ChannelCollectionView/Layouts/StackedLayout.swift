//
//  StackedLayout.swift
//  ChannelViewTest
//
//  Created by Otto Suess on 27.07.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import UIKit

final class StackedLayout: ChannelLayout {
    
    private let visibleCellHeaderHeight: CGFloat = 50
    private let easingOffset: CGFloat = 25
    private let bounceFactor: CGFloat = 0.1
    private let headerMargin: CGFloat = 10
    private let bottomMargin: CGFloat = 20
    
    var visibleIndices: Range<Int> {
        guard let collectionView = collectionView else { return 0..<1 }
        
        let start = Int((contentOffset.y - easingOffset - maxHeaderHeight - minHeaderHeight + headerMargin) / visibleCellHeaderHeight)
        let end = min(start + Int(collectionView.bounds.height / visibleCellHeaderHeight) + 2, collectionView.numberOfItems(inSection: 0))
        
        return start..<end
    }
    
    override var collectionViewContentSize: CGSize {
        guard let collectionView = collectionView else { return CGSize.zero }
        
        let itemCount = collectionView.numberOfItems(inSection: 0)
        let height = CGFloat(itemCount - 1) * visibleCellHeaderHeight + heightForItem(at: itemCount) + maxHeaderHeight + headerMargin + bottomMargin
        return CGSize(width: collectionView.bounds.width, height: height)
    }
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint) -> CGPoint {
        return overwriteContentOffset ?? proposedContentOffset
    }
    
    override func configure(attributes: UICollectionViewLayoutAttributes, for index: Int, of count: Int, in collectionView: UICollectionView) {
        attributes.zIndex = index + 1
        
        attributes.frame = CGRect(
            x: layoutMargin.left,
            y: visibleCellHeaderHeight * CGFloat(index),
            width: collectionView.bounds.width - layoutMargin.left - layoutMargin.right,
            height: heightForItem(at: index))
        
        let stickOffset = contentOffset.y - maxHeaderHeight - headerMargin
        
        if contentOffset.y < 0 {
            // bouncing (dragging down)
            attributes.frame.origin.y -= -contentOffset.y + bounceFactor * contentOffset.y * pow(CGFloat(index + 1), 1.5)
        } else if index == 0 && attributes.frame.minY < stickOffset {
            // first cell on top
            attributes.frame.origin.y = stickOffset
        } else if attributes.frame.minY < stickOffset - easingOffset {
            // cells on top
            attributes.frame.origin.y = stickOffset
        } else if index != 0 && attributes.frame.minY < stickOffset + easingOffset {
            // easing on top
            let normalized = (attributes.frame.minY - stickOffset + easingOffset) / (2 * easingOffset)
            attributes.frame.origin.y = stickOffset + (easingOffset * pow(normalized, 1.5))
        }
        
        attributes.frame.origin.y += maxHeaderHeight + headerMargin
        
        attributes.isHidden = !visibleIndices.contains(index)
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
}
