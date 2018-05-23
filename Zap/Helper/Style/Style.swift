//
//  Zap
//
//  Created by Otto Suess on 20.02.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import UIKit

struct UIViewStyle<T: UIView> {
    let styling: (T) -> Void
    
    func apply(to view: T) {
        styling(view)
    }
    
    func apply(to views: T...) {
        for view in views {
            styling(view)
        }
    }
    
    func apply(to views: T..., action: (T) -> Void) {
        for view in views {
            styling(view)
            action(view)
        }
    }
}

enum Style {
    static let button = UIViewStyle<UIButton> {
        $0.titleLabel?.font = Font.light
    }
    
    static let label = UIViewStyle<UILabel> {
        $0.font = Font.light
        $0.textColor = UIColor.zap.text
    }
    
    static let textField = UIViewStyle<UITextField> {
        $0.textColor = UIColor.zap.text
        $0.font = Font.light
    }
}
