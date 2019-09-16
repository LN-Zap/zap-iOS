//
//  Library
//
//  Created by 0 on 30.07.19.
//  Copyright © 2019 Zap. All rights reserved.
//

import Foundation

extension UIScreen {
    enum SizeType {
        case small
        case big
    }

    var sizeType: SizeType {
        return nativeBounds.height <= 1136 ? .small : .big
    }
}
