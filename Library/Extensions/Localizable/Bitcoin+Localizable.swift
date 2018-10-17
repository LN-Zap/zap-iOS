//
//  Library
//
//  Created by Otto Suess on 06.07.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation
import SwiftBTC

extension Bitcoin: Localizable {
    public var localized: String {
        return unit.localized
    }
}
