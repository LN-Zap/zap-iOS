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
        filter?.setValue("L", forKey: "inputCorrectionLevel")

        let scale = CGAffineTransform(scaleX: 10, y: 10)
        if let image = filter?.outputImage?.transformed(by: scale) {
            return UIImage(ciImage: image)
        }
        return nil
    }
}
