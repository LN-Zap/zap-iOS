//
//  Library
//
//  Created by 0 on 29.03.19.
//  Copyright © 2019 Zap. All rights reserved.
//

import Foundation
import SwiftBTC

final class CircleGraphView: UIView {
    struct Segment {
        let amount: Satoshi
        let color: UIColor
    }

    var emptyColor = UIColor.white

    var segments: [Segment] = [] {
        didSet {
            setNeedsDisplay()
        }
    }

    var arcWidth: CGFloat = 6.0

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func draw(_ rect: CGRect) {
        let segments = self.segments.filter { $0.amount > 0 }
        let fullCircle = 2 * CGFloat.pi
        let totalAmount = CGFloat(truncating: segments.reduce(0) { $0 + $1.amount } as NSDecimalNumber)

        let centerPoint = CGPoint(x: rect.midX, y: rect.midY)
        let radius = (max(rect.width, rect.height) - arcWidth) / 2

        guard let context = UIGraphicsGetCurrentContext() else { return }

        context.setLineWidth(arcWidth)
        context.setLineCap(.butt)

        let startAngle = -0.25 * fullCircle
        var previousAngle = startAngle

        if totalAmount == 0 {
            drawFullCircle(context: context, centerPoint: centerPoint, radius: radius, color: emptyColor)
        } else if segments.count == 1 {
            drawFullCircle(context: context, centerPoint: centerPoint, radius: radius, color: segments[0].color)
        } else {
            for (index, segment) in segments.enumerated() {
                let currentAngle: CGFloat
                if index == segments.count - 1 {
                    currentAngle = startAngle
                } else {
                    currentAngle = previousAngle + (CGFloat(truncating: segment.amount as NSDecimalNumber) / totalAmount) * fullCircle
                }

                context.setStrokeColor(segment.color.cgColor)
                context.addArc(center: centerPoint, radius: radius, startAngle: previousAngle, endAngle: currentAngle, clockwise: false)
                context.strokePath()

                previousAngle = currentAngle
            }
        }
    }

    private func drawFullCircle(context: CGContext, centerPoint: CGPoint, radius: CGFloat, color: UIColor) {
        context.setStrokeColor(color.cgColor)
        context.addArc(center: centerPoint, radius: radius, startAngle: 0, endAngle: 2 * .pi, clockwise: false)
        context.strokePath()
    }
}
