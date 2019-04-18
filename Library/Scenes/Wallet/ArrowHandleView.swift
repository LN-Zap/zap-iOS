//
//  Library
//
//  Created by 0 on 16.04.19.
//  Copyright © 2019 Zap. All rights reserved.
//

import Foundation

final class ArrowHandleView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        arrowLayer.setNeedsDisplay()
        backgroundColor = .clear
        arrowLayer.contentsScale = UIScreen.main.scale
    }

    public dynamic var progress: CGFloat = 0 {
        didSet {
            arrowLayer.progress = progress
            arrowLayer.setNeedsDisplay()
        }
    }

    fileprivate var arrowLayer: ArrowLayer {
        return layer as! ArrowLayer // swiftlint:disable:this force_cast
    }

    override public class var layerClass: AnyClass {
        return ArrowLayer.self
    }

    override public func action(for layer: CALayer, forKey event: String) -> CAAction? {
        if event == #keyPath(ArrowLayer.progress),
            let action = action(for: layer, forKey: #keyPath(backgroundColor)) as? CAAnimation {

            let animation = CABasicAnimation()
            animation.keyPath = #keyPath(ArrowLayer.progress)
            animation.fromValue = arrowLayer.progress
            animation.toValue = progress
            animation.beginTime = action.beginTime
            animation.duration = action.duration
            animation.speed = action.speed
            animation.timeOffset = action.timeOffset
            animation.repeatCount = action.repeatCount
            animation.repeatDuration = action.repeatDuration
            animation.autoreverses = action.autoreverses
            animation.fillMode = action.fillMode
            animation.timingFunction = action.timingFunction
            animation.delegate = action.delegate
            self.layer.add(animation, forKey: #keyPath(ArrowLayer.progress))
        }
        return super.action(for: layer, forKey: event)
    }
}

final class ArrowLayer: CALayer {
    @objc var progress: CGFloat = 0
    var lineWidth: CGFloat = 4

    override class func needsDisplay(forKey key: String) -> Bool {
        if key == #keyPath(progress) {
            return true
        }
        return super.needsDisplay(forKey: key)
    }

    override func draw(in ctx: CGContext) {
        super.draw(in: ctx)

        UIGraphicsPushContext(ctx)

        ctx.setLineWidth(lineWidth)
        ctx.setStrokeColor(UIColor.white.withAlphaComponent(0.75).cgColor)
        ctx.setLineCap(.round)

        let radius = lineWidth / 2
        let outerY = (bounds.height - lineWidth) * (1 - progress) + radius
        let pointY = (bounds.height - lineWidth) * progress + radius
        ctx.addLines(between: [
            CGPoint(x: radius, y: outerY),
            CGPoint(x: bounds.width / 2, y: pointY),
            CGPoint(x: bounds.width - radius, y: outerY)
        ])

        ctx.strokePath()

        UIGraphicsPopContext()
    }
}
