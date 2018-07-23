//
//  Zap
//
//  Created by Otto Suess on 20.01.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import UIKit

public extension UIColor {
    // swiftlint:disable:next type_name
    public enum zap {
        public static let charcoalGrey = color("charcoalGrey")
        public static let charcoalGreyLight = color("charcoalGreyLight")
        public static let white = color("white")
        public static let black = color("black")
        public static let lightGrey = color("lightGrey")
        public static let tomato = color("tomato")
        public static let nastyGreen = color("nastyGreen")
        public static let lightGreen = color("lightGreen")
        public static let lightMustard = color("lightMustard")
        public static let peach = color("peach")
        public static let warmGrey = color("warmGrey")
        
        private static func color(_ name: String) -> UIColor {
            return UIColor(named: name, in: Bundle.library, compatibleWith: nil) ?? UIColor.magenta
        }
    }
}
