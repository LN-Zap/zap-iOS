//
//  Library
//
//  Created by 0 on 08.07.19.
//  Copyright © 2019 Zap. All rights reserved.
//

import Foundation

enum Emoji {
    static func image(emoji: String) -> UIImage? {
        let attributes = [
            NSAttributedString.Key.foregroundColor: UIColor.yellow,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 100)
        ]
        let textSize = emoji.size(withAttributes: attributes)

        UIGraphicsBeginImageContextWithOptions(textSize, false, 0)
        emoji.draw(at: CGPoint.zero, withAttributes: attributes)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return image
    }
}
