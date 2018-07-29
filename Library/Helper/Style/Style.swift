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
    
    func apply(to views: [T]) {
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
        $0.titleLabel?.font = UIFont.zap.light
    }
    
    static let label = UIViewStyle<UILabel> {
        $0.font = UIFont.zap.light
        $0.textColor = UIColor.zap.black
    }
    
    static let textField = UIViewStyle<UITextField> {
        $0.textColor = UIColor.zap.black
        $0.font = UIFont.zap.light
    }
    
    static let textView = UIViewStyle<UITextView> {
        $0.textColor = UIColor.zap.black
        $0.font = UIFont.zap.light
    }
}
