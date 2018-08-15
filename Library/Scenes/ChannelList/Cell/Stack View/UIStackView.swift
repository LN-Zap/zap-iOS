//
//  Library
//
//  Created by Otto Suess on 07.08.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import UIKit

extension UIStackView {
    convenience init(elements: [StackViewElement]) {
        self.init()
        
        set(elements: elements)
    }
    
    func set(elements: [StackViewElement]) {
        for element in elements {
            addArrangedSubview(element.view)
        }
    }
    
    func clear() {
        for view in arrangedSubviews {
            view.removeFromSuperview()
        }
    }
}
