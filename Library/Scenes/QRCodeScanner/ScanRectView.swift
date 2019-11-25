//
//  Library
//
//  Created by Otto Suess on 08.08.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation

final class ScanRectView: UIView {
    var radius: CGFloat = 35
    var lineLength: CGFloat = 30
    var lineWidth: CGFloat = 1

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .clear
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // swiftlint:disable function_body_length
    override func draw(_ rect: CGRect) {

        let offset: CGFloat = 90
        let lineOffset = lineWidth / 2

        for index in 0..<4 {
            let path = UIBezierPath()

            let center = CGPoint(
                x: index == 0 || index == 3 ? bounds.width - radius - lineOffset : radius + lineOffset,
                y: index < 2 ? bounds.height - radius - lineOffset : radius + lineOffset
            )

            switch index {
            case 0:
                path.move(to: CGPoint(x: bounds.width - lineOffset, y: bounds.height - radius - lineLength))
            case 1:
                path.move(to: CGPoint(x: radius + lineLength, y: bounds.height - lineOffset))
            case 2:
                path.move(to: CGPoint(x: 0 + lineOffset, y: radius + lineLength))
            default:
                path.move(to: CGPoint(x: bounds.width - radius - lineLength, y: lineOffset))
            }

            path.addArc(
                withCenter: center,
                radius: radius,
                startAngle: (offset + CGFloat(index - 1) * 90) * .pi / 180,
                endAngle: (offset + CGFloat(index) * 90) * .pi / 180,
                clockwise: true)

            switch index {
            case 0:
                let xValue = bounds.width - radius
                let yValue = bounds.height - lineOffset
                path.move(to: CGPoint(x: xValue, y: yValue))
                path.addLine(to: CGPoint(x: xValue - lineLength, y: yValue))
            case 1:
                let yValue = bounds.height - radius
                path.move(to: CGPoint(x: lineOffset, y: yValue))
                path.addLine(to: CGPoint(x: lineOffset, y: yValue - lineLength))
            case 2:
                path.move(to: CGPoint(x: radius, y: lineOffset))
                path.addLine(to: CGPoint(x: radius + lineLength, y: lineOffset))
            default:
                let xValue = bounds.width - lineOffset
                path.move(to: CGPoint(x: xValue, y: radius))
                path.addLine(to: CGPoint(x: xValue, y: radius + lineLength))
            }

            path.lineWidth = lineWidth
            UIColor.Zap.lightningOrange.set()

            path.stroke()
        }
    }
}
