//
//  LABColor.swift
//  ChannelViewTest
//
//  Created by Otto Suess on 29.07.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import UIKit

// swiftlint:disable identifier_name

// CIELAB color space
struct LabColor {
    let l: CGFloat
    let a: CGFloat
    let b: CGFloat
    
    init(color: UIColor) {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        color.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        r = (r > 0.04045) ? pow((r + 0.055) / 1.055, 2.4) : r / 12.92
        g = (g > 0.04045) ? pow((g + 0.055) / 1.055, 2.4) : g / 12.92
        b = (b > 0.04045) ? pow((b + 0.055) / 1.055, 2.4) : b / 12.92
        
        var x = (r * 0.4124 + g * 0.3576 + b * 0.1805) / 0.95047
        var y = (r * 0.2126 + g * 0.7152 + b * 0.0722) / 1.00000
        var z = (r * 0.0193 + g * 0.1192 + b * 0.9505) / 1.08883
        
        x = (x > 0.008856) ? pow(x, 1 / 3) : (7.787 * x) + 16 / 116
        y = (y > 0.008856) ? pow(y, 1 / 3) : (7.787 * y) + 16 / 116
        z = (z > 0.008856) ? pow(z, 1 / 3) : (7.787 * z) + 16 / 116
        
        self.l = (116 * y) - 16
        self.a = 500 * (x - y)
        self.b = 200 * (y - z)
    }
    
    // CIE94 - https://en.wikipedia.org/wiki/Color_difference#CIE94
    func distance(to color: LabColor) -> CGFloat {
        let kL: CGFloat = 1
        let kC: CGFloat = 1
        let kH: CGFloat = 1
        let k1: CGFloat = 0.045
        let k2: CGFloat = 0.015
        let deltaL = l - color.l
        let C1 = sqrt((a * a) + (b * b))
        let C2 = sqrt((color.a * color.a) + (color.b * color.b))
        let deltaC = C1 - C2
        let deltaH = sqrt(pow((a - color.a), 2) + pow((b - color.b), 2) - pow(deltaC, 2))
        let sL: CGFloat = 1
        let sC = 1 + k1 * (sqrt((a * a) + (b * b)))
        let sH = 1 + k2 * (sqrt((a * a) + (b * b)))
        
        return sqrt(pow((deltaL / (kL * sL)), 2) + pow((deltaC / (kC * sC)), 2) + pow((deltaH / (kH * sH)), 2))
    }
}
