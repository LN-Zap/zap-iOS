//
//  Zap
//
//  Created by Otto Suess on 23.04.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import UIKit

final class PinView: UIStackView {
    var activeCount: Int = 0 {
        didSet {
            for (count, view) in arrangedSubviews.enumerated() {
                view.backgroundColor = count < activeCount ? .white : .black
            }
        }
    }
    
    var characterCount: Int = 0 {
        didSet {
            for view in arrangedSubviews {
                view.removeFromSuperview()
            }
            
            let circleSize = bounds.height
            for _ in (0..<characterCount) {
                let circleView = UIView()
                circleView.backgroundColor = .black
                NSLayoutConstraint(item: circleView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: circleSize).isActive = true
                NSLayoutConstraint(item: circleView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: circleSize).isActive = true
                circleView.layer.cornerRadius = circleSize / 2
                addArrangedSubview(circleView)
            }

        }
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        
        distribution = .equalSpacing
    }
}
