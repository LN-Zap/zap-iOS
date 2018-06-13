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
        static let charcoalGrey = color("charcoalGrey")
        static let charcoalGreyLight = color("charcoalGreyLight")
        static let white = color("white")
        static let black = color("black")
        static let lightGrey = color("lightGrey")
        static let tomato = color("tomato")
        static let nastyGreen = color("nastyGreen")
        static let lightGreen = color("lightGreen")
        static let lightMustard = color("lightMustard")
        static let peach = color("peach")
        static let warmGrey = color("warmGrey")
        
        private static func color(_ name: String) -> UIColor {
            return UIColor(named: name, in: Bundle.zap, compatibleWith: nil) ?? UIColor.magenta
        }
    }
}
