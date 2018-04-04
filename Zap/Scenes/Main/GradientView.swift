//
//  Zap
//
//  Created by Otto Suess on 26.03.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import UIKit

final class GradientView: UIView {
    override open class var layerClass: AnyClass {
        return CAGradientLayer.classForCoder()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        let gradientLayer = layer as? CAGradientLayer
        
        gradientLayer?.startPoint = CGPoint(x: 0.0, y: 1.0)
        gradientLayer?.endPoint = CGPoint(x: 1.0, y: 1.0)
        gradientLayer?.colors = [Color.bottomGradientLeft.cgColor, Color.bottomGradientRight.cgColor]
    }
}
