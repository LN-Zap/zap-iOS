//
//  Zap
//
//  Created by Otto Suess on 26.03.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import UIKit

class GradientView: UIView {
    var gradient: [UIColor] = [UIColor.zap.lightMustard, UIColor.zap.peach] {
        didSet {
            updateColors()
        }
    }
    
    var gradientLayer: CAGradientLayer?
    
    override open class var layerClass: AnyClass {
        return CAGradientLayer.classForCoder()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        let gradientLayer = layer as? CAGradientLayer
        
        gradientLayer?.startPoint = CGPoint(x: 0.0, y: 1.0)
        gradientLayer?.endPoint = CGPoint(x: 1.0, y: 1.0)
        self.gradientLayer = gradientLayer
        updateColors()
    }
    
    private func updateColors() {
        gradientLayer?.colors = gradient.map { $0.cgColor }
    }
}
