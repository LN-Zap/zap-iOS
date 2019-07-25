//
//  Library
//
//  Created by 0 on 25.07.19.
//  Copyright © 2019 Zap. All rights reserved.
//

import Foundation

extension UILabel {
    func setMarkdown(_ markdownText: String, fontSize: CGFloat, weight: UIFont.Weight, boldWeight: UIFont.Weight) {
        font = UIFont.systemFont(ofSize: fontSize, weight: weight)

        let boldFont = UIFont.systemFont(ofSize: 40, weight: boldWeight)

        let attributedString = NSMutableAttributedString(string: markdownText.replacingOccurrences(of: "**", with: ""))

        var index = 0
        for (componentIndex, component) in markdownText.components(separatedBy: "**").enumerated() {
            if componentIndex % 2 == 1 {
                attributedString.addAttribute(.font, value: boldFont, range: NSRange(location: index, length: component.count))
            }
            index += component.count
        }

        attributedText = attributedString
    }
}
