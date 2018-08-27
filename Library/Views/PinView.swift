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
    
    func startShakeAnimation(completion: @escaping () -> Void) {
        let translation: CGFloat = 10
        let propertyAnimator = UIViewPropertyAnimator(duration: 0.4, dampingRatio: 0.4) {
            self.transform = CGAffineTransform(translationX: translation, y: 0)
        }
        
        propertyAnimator.addAnimations({
            self.transform = CGAffineTransform(translationX: -translation, y: 0)
        }, delayFactor: 0.2)
        
        propertyAnimator.addAnimations({
            self.transform = CGAffineTransform(translationX: 0, y: 0)
        }, delayFactor: 0.4)

        propertyAnimator.addCompletion { _ in completion() }

        propertyAnimator.startAnimation()
    }
}
