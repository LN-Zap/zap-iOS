//
//  ExposedLayout.swift
//  ChannelViewTest
//
//  Created by Otto Suess on 27.07.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import UIKit

protocol ExposedLayoutDelegate: class {
    func didDismissExposedCell()
}

final class ExposedLayout: ChannelLayout {
    private let exposedIndex: Int
    private let visibleIndices: Range<Int>
    
    private let minimumScale: CGFloat = 0.9
    private let bottomStackHeight: CGFloat = 40
    
    private var exposedCell: UICollectionViewCell?
    private var panGestureRecognizer: UIPanGestureRecognizer?
    private var animator: UIViewPropertyAnimator?
    
    weak var delegate: ExposedLayoutDelegate?
    
    init(exposedIndex: Int, visibleIndices: Range<Int>) {
        self.exposedIndex = exposedIndex
        self.visibleIndices = visibleIndices
        
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint) -> CGPoint {
        return CGPoint.zero
    }
    
    override var collectionViewContentSize: CGSize {
        guard let collectionView = collectionView else { return CGSize.zero }
        var size = collectionView.bounds.size
        size.height -= collectionView.contentInset.top + collectionView.contentInset.bottom
        return size
    }
    
    override func prepare() {
        super.prepare()
        
        setupPanGestureRecognizer()
    }
    
    func setupPanGestureRecognizer() {
        guard self.panGestureRecognizer == nil else { return }
        
        exposedCell = collectionView?.cellForItem(at: IndexPath(item: exposedIndex, section: 0))
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handleCollapsePanGesture))
        exposedCell?.addGestureRecognizer(panGestureRecognizer)
        self.panGestureRecognizer = panGestureRecognizer
    }
    
    override func configure(attributes: UICollectionViewLayoutAttributes, for index: Int, of count: Int, in collectionView: UICollectionView) {
        
        let cellWidth = collectionView.bounds.width - layoutMargin.left - layoutMargin.right
        
        if index == exposedIndex {
            attributes.frame = CGRect(
                x: layoutMargin.left,
                y: 0,
                width: cellWidth,
                height: heightForItem(at: index))
            attributes.zIndex = 1000
        } else {
            let height = heightForItem(at: index)
            attributes.frame = CGRect(
                x: layoutMargin.left,
                y: 0,
                width: cellWidth,
                height: height)
            
            attributes.transform = transform(for: index)
            attributes.zIndex = index
        }
        
        attributes.isHidden = !visibleIndices.contains(index)
    }
    
    private func transform(for index: Int) -> CGAffineTransform {
        guard let collectionView = collectionView else { return CGAffineTransform.identity }
        
        let index = index - visibleIndices.lowerBound
        let count = visibleIndices.count
        let height = heightForItem(at: index)
        let hiddenElementHeight = bottomStackHeight / CGFloat(count)
        let scaleYOffset = height / 2
        let scale = 1 - (1 - CGFloat(index) / CGFloat(count - 1)) * (1 - minimumScale)
        
        return CGAffineTransform.identity
            .translatedBy(x: 0, y: -scaleYOffset + CGFloat(index) * hiddenElementHeight + collectionView.bounds.height - bottomStackHeight)
            .scaledBy(x: scale, y: scale)
            .translatedBy(x: 0, y: scaleYOffset)
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    // MARK: custom gestures
    
    @objc func handleCollapsePanGesture(gestureRecognizer: UIPanGestureRecognizer) {
        switch gestureRecognizer.state {
        case .began:
            animator = UIViewPropertyAnimator(duration: 0.3, curve: .easeOut) { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.exposedCell?.transform = strongSelf.transform(for: strongSelf.exposedIndex)
            }
            animator?.addCompletion { [weak self] position in
                guard position == .end else { return }
                self?.delegate?.didDismissExposedCell()
            }
            animator?.startAnimation()
            animator?.pauseAnimation()
        case .changed:
            guard let collectionView = collectionView else { return }
            animator?.fractionComplete = max(0, gestureRecognizer.translation(in: collectionView).y) / collectionView.bounds.height
        case .ended:
            animator?.isReversed = gestureRecognizer.velocity(in: collectionView).y <= 0
                || (gestureRecognizer.translation(in: collectionView).y < 100 && gestureRecognizer.velocity(in: collectionView).y < 300)
            
            animator?.continueAnimation(withTimingParameters: nil, durationFactor: 1)
        case .cancelled:
            animator?.continueAnimation(withTimingParameters: nil, durationFactor: 1)
        default:
            print(gestureRecognizer)
        }
    }
    
    func removeGestureRecognizer() {
        guard let panGestureRecognizer = panGestureRecognizer else { return }
        exposedCell?.removeGestureRecognizer(panGestureRecognizer)
    }
}
