//
//  Zap
//
//  Created by Otto Suess on 08.02.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import UIKit

final class LineView: UIView {
    var color = UIColor(hex: 0xD6D6D6)
    
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        context?.setLineWidth(1)
        context?.setStrokeColor(color.cgColor)
        
        let points: [CGPoint]
        if bounds.width > bounds.height {
            points = [CGPoint(x: 0, y: 0), CGPoint(x: bounds.width, y: 0)]
        } else {
            points = [CGPoint(x: 0, y: 0), CGPoint(x: 0, y: bounds.height)]
        }
        
        context?.strokeLineSegments(between: points)
    }
}
