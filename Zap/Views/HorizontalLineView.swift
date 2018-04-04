//
//  Zap
//
//  Created by Otto Suess on 08.02.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import Foundation

final class HorizontalLineView: UIView {
    var color = UIColor(hex: 0xD6D6D6)
    
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        context?.setLineWidth(1)
        context?.setStrokeColor(color.cgColor)
        let points = [CGPoint(x: 0, y: bounds.height), CGPoint(x: bounds.width, y: bounds.height)]
        context?.strokeLineSegments(between: points)
    }
}
