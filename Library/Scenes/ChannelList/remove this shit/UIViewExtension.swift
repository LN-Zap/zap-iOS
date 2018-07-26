//
//  Zap
//
//  Created by Otto Suess on 05.04.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import UIKit

extension UIView {
    static func nibForClass() -> Self {
        return loadNib(self)
    }
    
    static func loadNib<A>(_ owner: AnyObject, bundle: Bundle = Bundle.library) -> A {
        guard
            let nibName = NSStringFromClass(classForCoder()).components(separatedBy: ".").last,
            let nib = bundle.loadNibNamed(nibName, owner: owner, options: nil)
            else { fatalError("Can load nib") }
        
        for item in nib {
            if let item = item as? A {
                return item
            }
        }
        
        fatalError("Can load nib")
    }
    
    func addTransitionFade(_ duration: TimeInterval = 0.5) {
        let animation = CATransition()

        animation.type = kCATransitionFade
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionDefault)
        animation.fillMode = kCAFillModeForwards
        animation.duration = duration

        layer.add(animation, forKey: "kCATransitionFade")
    }
}
