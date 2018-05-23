//
//  Zap
//
//  Created by Otto Suess on 20.01.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import UIKit

extension UIColor {
    // swiftlint:disable:next type_name
    enum zap {
        static let tint = bottomGradientRight
        
        static let darkBackground = UIColor(hex: 0x31333b)
        static let mediumBackground = UIColor(hex: 0x363943)
        static let searchBackground = UIColor(hex: 0xf4f4f4)
        
        static let text = UIColor(hex: 0x2e2e2e)
        static let disabled = UIColor(hex: 0xd6d6d6)
        
        static let red = UIColor(hex: 0xee4646)
        static let green = UIColor(hex: 0x77a33f)
        static let lightGreen = UIColor(hex: 0xb8e986)
        
        static let bottomGradientLeft = UIColor(hex: 0xf7ce68)
        static let bottomGradientRight = UIColor(hex: 0xfbab7e)
        
        static let darkTableViewSeparator = UIColor(hex: 0x989898)
    }
    
    private convenience init(red: Int, green: Int, blue: Int) {
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(hex: Int) {
        self.init(red: (hex >> 16) & 0xff, green: (hex >> 8) & 0xff, blue: hex & 0xff)
    }
}
