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
        
        public static let backgroundGradientTop = color("backgroundGradientTop")
        public static let backgroundGradientBottom = color("backgroundGradientBottom")
        
        private static func color(_ name: String) -> UIColor {
            return UIColor(named: name, in: Bundle.library, compatibleWith: nil) ?? UIColor.magenta
        }
    }
    
    private convenience init(red: Int, green: Int, blue: Int) {
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(hex: Int) {
        self.init(red: (hex >> 16) & 0xff, green: (hex >> 8) & 0xff, blue: hex & 0xff)
    }
    
    convenience init?(hex: String) {
        var cString = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if cString.hasPrefix("#") {
            cString.remove(at: cString.startIndex)
        }
        
        if cString.count != 6 {
            return nil
        }
        
        var rgbValue: UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)

        
        self.init(hex: Int(rgbValue))
    }
}
