//
//  ChannelViewTest
//
//  Created by Otto Suess on 27.07.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import UIKit

final class ChannelCollectionView: UICollectionView {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        assert(collectionViewLayout is StackedLayout, "Wrong layout type")
        
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        alwaysBounceVertical = true
        
        self.delegate = self
    }
    
    private var oldContentOffset: CGPoint?
    
    private var exposedItemIndexPath: IndexPath? {
        didSet {
            if oldValue == nil, let exposedItemIndexPath = exposedItemIndexPath,
                let stackedLayout = collectionViewLayout as? StackedLayout {
                oldContentOffset = contentOffset
                let oldHeaderHeight = stackedLayout.headerHeight
                let exposedLayout = ExposedLayout(exposedIndex: exposedItemIndexPath.item, visibleIndices: stackedLayout.visibleIndices)
                exposedLayout.delegate = self
                exposedLayout.overwriteHeaderHeight = oldHeaderHeight
                setCollectionViewLayout(exposedLayout, animated: true)
                alwaysBounceVertical = false
            } else if oldValue != nil && exposedItemIndexPath == nil {
                if let exposedLayout = collectionViewLayout as? ExposedLayout {
                    exposedLayout.removeGestureRecognizer()
                }
                let stackedLayout = StackedLayout()
                stackedLayout.overwriteContentOffset = oldContentOffset
                setCollectionViewLayout(stackedLayout, animated: true) { _ in
                    stackedLayout.overwriteContentOffset = nil
                }
                alwaysBounceVertical = true
            }
        }
    }
    
    func switchToStackView() {
        exposedItemIndexPath = nil
    }
}

extension ChannelCollectionView: ExposedLayoutDelegate {
    func didDismissExposedCell() {
        exposedItemIndexPath = nil
    }
}

extension ChannelCollectionView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard collectionView.numberOfItems(inSection: 0) > 1 else { return }
        
        if exposedItemIndexPath != nil {
            exposedItemIndexPath = nil
        } else {
            exposedItemIndexPath = indexPath
        }
    }
}
