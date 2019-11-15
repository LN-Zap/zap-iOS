//
//  Zap
//
//  Created by Otto Suess on 20.01.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import UIKit

public extension UIColor {
    enum Zap {
        public static let black = color("black")
        public static let white = color("white")
        public static let gray = color("gray")
        public static let invisibleGray = color("invisibleGray")
        public static let deepSeaBlue = color("deepSeaBlue")
        public static let lightningBlue = color("lightningBlue")
        public static let lightningBlueGradient = [color("lightningBlue"), color("lightningBlueGradient")]
        public static let lightningOrange = color("lightningOrange")
        public static let lightningOrangeGradient = [color("lightningOrange"), color("lightningOrangeGradient")]
        public static let seaBlue = color("seaBlue")
        public static let seaBlueGradient = color("seaBlueGradient")
        public static let seaBlueSkeleton = color("seaBlueSkeleton")
        public static let superRed = color("superRed")
        public static let superGreen = color("superGreen")
        public static let purple = color("purple")

        // concrete uses of previously defined colors, to make changing easier
        // throughout the app.
        public static let background = deepSeaBlue

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
}
