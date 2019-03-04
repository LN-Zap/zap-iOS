//
//  Zap
//
//  Created by Otto Suess on 08.02.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import UIKit

public final class LineView: UIView {
    var color = UIColor.Zap.gray

    override public func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        context?.setLineWidth(0.5)
        context?.setStrokeColor(color.cgColor)

        let points: [CGPoint]
        if bounds.width > bounds.height {
            points = [CGPoint(x: 0, y: rect.maxY / 2), CGPoint(x: bounds.width, y: rect.maxY / 2)]
        } else {
            points = [CGPoint(x: rect.maxX / 2, y: 0), CGPoint(x: rect.maxX / 2, y: bounds.height)]
        }

        context?.strokeLineSegments(between: points)
    }
}
