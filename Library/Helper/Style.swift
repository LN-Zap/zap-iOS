//
//  Zap
//
//  Created by Otto Suess on 20.02.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import UIKit

public struct UIViewStyle<T: UIView> {
    let styling: (T) -> Void

    public func apply(to view: T) {
        styling(view)
    }

    func apply(to views: T...) {
        for view in views {
            styling(view)
        }
    }

    func with(_ adjustment: @escaping (T) -> Void) -> UIViewStyle<T> {
        let styling = self.styling
        return UIViewStyle<T> {
            styling($0)
            adjustment($0)
        }
    }
}

public enum Style {
    enum Label {
        static func custom(
            color: UIColor = UIColor.Zap.black,
            font: UIFont = UIFont.Zap.light,
            fontSize: CGFloat = 17,
            alignment: NSTextAlignment = .left
            ) -> UIViewStyle<UILabel> {
            return UIViewStyle<UILabel> {
                $0.font = UIFontMetrics(forTextStyle: .body).scaledFont(for: font.withSize(fontSize))
                $0.textColor = color
                $0.textAlignment = alignment
                $0.adjustsFontForContentSizeCategory = true
            }
        }

        static let boldTitle = UIViewStyle<UILabel> {
            $0.font = UIFontMetrics(forTextStyle: .title1).scaledFont(for: UIFont.Zap.bold.withSize(40))
            $0.textColor = UIColor.Zap.white
            $0.adjustsFontForContentSizeCategory = true
        }

        static let title = UIViewStyle<UILabel> {
            $0.font = UIFontMetrics(forTextStyle: .title1).scaledFont(for: UIFont.Zap.regular.withSize(40))
            $0.textColor = UIColor.Zap.white
            $0.adjustsFontForContentSizeCategory = true
        }
        
        static let largeAmount = UIViewStyle<UILabel> {
            $0.font = UIFontMetrics(forTextStyle: .title1).scaledFont(for: UIFont.systemFont(ofSize: 80, weight: .regular))
            $0.textColor = UIColor.Zap.white
            $0.adjustsFontForContentSizeCategory = true
        }

        static let body = UIViewStyle<UILabel> {
            $0.font = UIFontMetrics(forTextStyle: .body).scaledFont(for: UIFont.Zap.light.withSize(17))
            $0.textColor = UIColor.Zap.white
            $0.adjustsFontForContentSizeCategory = true
        }

        static let subHeadline = UIViewStyle<UILabel> {
            $0.font = UIFontMetrics(forTextStyle: .subheadline).scaledFont(for: UIFont.Zap.light.withSize(15))
            $0.textColor = UIColor.Zap.gray
            $0.adjustsFontForContentSizeCategory = true
        }

        static let headline = UIViewStyle<UILabel> {
            $0.font = UIFontMetrics(forTextStyle: .body).scaledFont(for: UIFont.Zap.regular.withSize(17))
            $0.textColor = UIColor.Zap.white
            $0.adjustsFontForContentSizeCategory = true
        }

        static let footnote = UIViewStyle<UILabel> {
            $0.font = UIFontMetrics(forTextStyle: .body).scaledFont(for: UIFont.Zap.regular.withSize(13))
            $0.textColor = UIColor.Zap.gray
            $0.adjustsFontForContentSizeCategory = true
        }

        static let caption = UIViewStyle<UILabel> {
            $0.font = UIFontMetrics(forTextStyle: .caption1).scaledFont(for: UIFont.Zap.regular.withSize(10))
            $0.textColor = UIColor.Zap.gray
            $0.adjustsFontForContentSizeCategory = true
        }
    }

    public enum Button {
        public static func custom(color: UIColor = UIColor.Zap.lightningOrange, fontSize: CGFloat = 17) -> UIViewStyle<UIButton> {
            return UIViewStyle<UIButton> {
                $0.titleLabel?.font = UIFontMetrics(forTextStyle: .body).scaledFont(for: UIFont.Zap.regular.withSize(fontSize))
                $0.setTitleColor(color, for: .normal)
                $0.titleLabel?.adjustsFontForContentSizeCategory = true
            }
        }

        static let background = UIViewStyle<UIButton> {
            $0.titleLabel?.font = UIFontMetrics(forTextStyle: .body).scaledFont(for: UIFont.Zap.regular.withSize(17))
            $0.backgroundColor = UIColor.Zap.seaBlue
            $0.layer.cornerRadius = 14
        }
    }

    static func textField(color: UIColor = UIColor.Zap.black) -> UIViewStyle<UITextField> {
        return UIViewStyle<UITextField> {
            $0.textColor = color
            $0.font = UIFont.Zap.light
        }
    }

    static let textView = UIViewStyle<UITextView> {
        $0.textColor = UIColor.Zap.black
        $0.font = UIFont.Zap.light
    }
}
