//
//  Zap
//
//  Created by Otto Suess on 11.04.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation

extension UIButton {
    func alignImageAndTitleVertically(padding: CGFloat = 7.0) {
        guard
            let imageSize = imageView?.frame.size,
            let titleSize = titleLabel?.frame.size
            else { return }
        
        let totalHeight = imageSize.height + titleSize.height + padding
        imageEdgeInsets = UIEdgeInsets(top: -(totalHeight - imageSize.height), left: 0, bottom: 0, right: -titleSize.width)
        titleEdgeInsets = UIEdgeInsets(top: 0, left: -imageSize.width, bottom: -(totalHeight - titleSize.height), right: 0)
    }
}
