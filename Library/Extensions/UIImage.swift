//
//  Zap
//
//  Created by Otto Suess on 20.01.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import CoreImage
import SwiftBTC
import UIKit

extension UIImage {
    static func qrCode(from string: String) -> UIImage? {
        let stringData = string.data(using: .isoLatin1)
        let filter = CIFilter(name: "CIQRCodeGenerator")
        filter?.setValue(stringData, forKey: "inputMessage")
        filter?.setValue("H", forKey: "inputCorrectionLevel")

        let scale = CGAffineTransform(scaleX: 10, y: 10)
        if let image = filter?.outputImage?.transformed(by: scale) {
            return UIImage(ciImage: image)
        }
        return nil
    }
    
    static func circle(diameter: CGFloat, color: UIColor) -> UIImage? {
        defer {
            UIGraphicsEndImageContext()
        }
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: diameter, height: diameter), false, 0)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        context.saveGState()
        
        let rect = CGRect(x: 0, y: 0, width: diameter, height: diameter)
        context.setFillColor(color.cgColor)
        context.fillEllipse(in: rect)
        
        context.restoreGState()
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
