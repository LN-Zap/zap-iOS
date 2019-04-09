//
//  Library
//
//  Created by 0 on 29.03.19.
//  Copyright © 2019 Zap. All rights reserved.
//

import Foundation

final class CircleView: UIView {
    var color = UIColor.green

    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }

        let radius = min(rect.width, rect.height) / 2
        context.setFillColor(color.cgColor)
        context.fillEllipse(in: CGRect(x: bounds.midX - radius, y: bounds.midY - radius, width: radius * 2, height: radius * 2))
    }
}
