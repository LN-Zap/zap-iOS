//
//  Library
//
//  Created by 0 on 22.07.19.
//  Copyright © 2019 Zap. All rights reserved.
//

import Foundation

final class PulsatingLayer: CALayer {
    override func layoutSublayers() {
        super.layoutSublayers()

        updateAnimation()
    }

    override var bounds: CGRect {
        didSet {
            guard oldValue != bounds else { return }
            updateAnimation()
        }
    }

    static let animation: CABasicAnimation = {
        let animation = CABasicAnimation(keyPath: "backgroundColor")
        animation.fromValue = UIColor.Zap.seaBlue.cgColor
        animation.toValue = UIColor.Zap.seaBlueSkeleton.cgColor
        animation.repeatCount = .infinity
        animation.autoreverses = true
        animation.duration = 0.85
        animation.beginTime = 1
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        animation.isRemovedOnCompletion = false
        return animation
    }()

    private func updateAnimation() {
        layoutIfNeeded()
        removeAllAnimations()
        add(PulsatingLayer.animation, forKey: "shimmer")
    }
}

final class SkeletonView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        layer.cornerRadius = 4
    }

    override class var layerClass: AnyClass {
        return PulsatingLayer.self
    }
}
