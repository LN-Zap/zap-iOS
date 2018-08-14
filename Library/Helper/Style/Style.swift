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
}

enum Style {
    enum Label {
        static func custom(
            color: UIColor = UIColor.zap.black,
            font: UIFont = UIFont.zap.light,
            fontSize: CGFloat = 17,
            alignment: NSTextAlignment = .left
            ) -> UIViewStyle<UILabel> {
            return UIViewStyle<UILabel> {
                $0.font = font.withSize(fontSize)
                $0.textColor = color
                $0.textAlignment = alignment
                $0.adjustsFontForContentSizeCategory = true
            }
        }
        
        static let title = UIViewStyle<UILabel> {
            $0.font = UIFontMetrics(forTextStyle: .title1).scaledFont(for: UIFont.zap.regular.withSize(40))
            $0.textColor = .white
            $0.adjustsFontForContentSizeCategory = true
        }
        
        static let body = UIViewStyle<UILabel> {
            $0.font = UIFontMetrics(forTextStyle: .body).scaledFont(for: UIFont.zap.light.withSize(17))
            $0.textColor = .white
            $0.adjustsFontForContentSizeCategory = true
        }
        
        static let headline = UIViewStyle<UILabel> {
            $0.font = UIFontMetrics(forTextStyle: .body).scaledFont(for: UIFont.zap.regular.withSize(17))
            $0.textColor = .white
            $0.adjustsFontForContentSizeCategory = true
        }
    }
    
    static func button(color: UIColor = UIColor.zap.lightningOrange, backgroundColor: UIColor = UIColor.clear, fontSize: CGFloat = 17) -> UIViewStyle<UIButton> {
        return UIViewStyle<UIButton> {
            $0.titleLabel?.font = UIFontMetrics(forTextStyle: .body).scaledFont(for: UIFont.zap.regular.withSize(17))
            $0.setTitleColor(color, for: .normal)
            $0.titleLabel?.adjustsFontForContentSizeCategory = true
            if backgroundColor != .clear {
                $0.backgroundColor = backgroundColor
                $0.layer.cornerRadius = 14
            }
        }
    }
    
    static func textField(color: UIColor = UIColor.zap.black) -> UIViewStyle<UITextField> {
        return UIViewStyle<UITextField> {
            $0.textColor = color
            $0.font = UIFont.zap.light
        }
    }
    
    static let textView = UIViewStyle<UITextView> {
        $0.textColor = UIColor.zap.black
        $0.font = UIFont.zap.light
    }
}
