//
//  Library
//
//  Created by Otto Suess on 06.07.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import BTCUtil
import Foundation

extension Bitcoin: Localizable {
    public var localized: String {
        return unit.localized
    }
}
