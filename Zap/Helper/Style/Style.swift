//
//  Zap
//
//  Created by Otto Suess on 20.02.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import Foundation

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
}

enum Style {
    static let button = UIViewStyle<UIButton> {
        $0.titleLabel?.font = Font.light
    }
    
    static let buttonBorder = UIViewStyle<UIButton> {
        $0.titleLabel?.font = Font.light.withSize(12)
        $0.layer.cornerRadius = 8
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.white.cgColor
        $0.tintColor = .white
    }

    static let buttonBackground = UIViewStyle<UIButton> {
        $0.titleLabel?.font = Font.light.withSize(18)
        $0.layer.cornerRadius = 8
        $0.backgroundColor = UIColor.red
        $0.tintColor = .white
    }
    
    static let label = UIViewStyle<UILabel> {
        $0.font = Font.light
        $0.textColor = Color.textColor
    }
}
