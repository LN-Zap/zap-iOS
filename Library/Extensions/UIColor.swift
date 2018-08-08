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
        public static let deepSeaBlue = color("deepSeaBlue")
        public static let lightningOrange = color("lightningOrange")
        public static let lightningOrangeGradient = color("lightningOrangeGradient")
        public static let seaBlue = color("seaBlue")
        public static let seaBlueGradient = color("seaBlueGradient")
        
        public static let white = color("white")
        public static let black = color("black")
        public static let lightGrey = color("lightGrey")
        public static let tomato = color("tomato")
        public static let nastyGreen = color("nastyGreen")
        public static let lightGreen = color("lightGreen")
        public static let warmGrey = color("warmGrey")
        
        static let validNodeColors: [UIColor] =
            [
                0xe6194b,
                0x3cb44b,
                0xffe119,
                0x0082c8,
                0xf58231,
                0x911eb4,
                0x46f0f0,
                0xf032e6,
                0xd2f53c,
                0xfabebe,
                0x008080,
                0xe6beff,
                0xaa6e28,
                0xfffac8,
                0x800000,
                0xaaffc3,
                0x808000,
                0xffd8b1,
                0x000080,
                0x808080,
                0xFFFFFF,
                0x000000
            ]
            .map { UIColor(hex: $0) }
        
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
