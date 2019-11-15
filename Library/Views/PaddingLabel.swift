//
//  Library
//
//  Created by Otto Suess on 09.08.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation

class PaddingLabel: UILabel {
    var edgeInsets = UIEdgeInsets.zero

    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: edgeInsets))
    }

    override var intrinsicContentSize: CGSize {
        var size = super.intrinsicContentSize
        size.width += edgeInsets.left + edgeInsets.right
        size.height += edgeInsets.top + edgeInsets.bottom
        return size
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let superSizeThatFits = super.sizeThatFits(size)
        let width = superSizeThatFits.width + edgeInsets.left + edgeInsets.right
        let heigth = superSizeThatFits.height + edgeInsets.top + edgeInsets.bottom
        return CGSize(width: width, height: heigth)
    }
}
