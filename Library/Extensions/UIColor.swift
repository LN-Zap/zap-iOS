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
        
        static let validNodeColors: [UIColor] = [
            0x1abc9c,
            0x2ecc71,
            0x3498db,
            0x9b59b6,
            0x34495e,
            0x16a085,
            0x27ae60,
            0x2980b9,
            0x8e44ad,
            0x2c3e50,
            0xf1c40f,
            0xe67e22,
            0xe74c3c,
            0xecf0f1,
            0x95a5a6,
            0xf39c12,
            0xd35400,
            0xc0392b,
            0xbdc3c7,
            0x7f8c8d,
            0xC4E538,
            0x0652DD,
            0x1B1464,
            0xA3CB38,
            0x12CBC4,
            0xf8e71c,
            0x000000
        ].map { UIColor(hex: $0) }
        
        private static func color(_ name: String) -> UIColor {
            return UIColor(named: name, in: Bundle.library, compatibleWith: nil) ?? UIColor.magenta
        }
    }
    
    var verified: UIColor {
        var smallestDistance: CGFloat = CGFloat.greatestFiniteMagnitude
        var closestColor = UIColor.black
        
        for color in UIColor.zap.validNodeColors {
            let distance = self.distance(to: color)
            if distance < smallestDistance {
                smallestDistance = distance
                closestColor = color
            }
        }
        
        return closestColor
    }

    var darker: UIColor {
        return darkerColor(removeBrightness: 0.2)
    }
    
    var isLight: Bool {
        var white: CGFloat = 0
        getWhite(&white, alpha: nil)
        return white > 0.5
    }
    
    private func darkerColor(removeBrightness val: CGFloat) -> UIColor {
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0
        
        guard getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) else { return self }
        
        return UIColor(hue: hue, saturation: saturation, brightness: max(0, brightness - val), alpha: alpha)
    }
    
    private func distance(to color2: UIColor) -> CGFloat {
        let color1 = LabColor(color: self)
        let color2 = LabColor(color: color2)
        return color1.distance(to: color2)
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
