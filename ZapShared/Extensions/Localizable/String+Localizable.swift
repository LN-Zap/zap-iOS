//
//  Zap
//
//  Created by Otto Suess on 05.04.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation

extension String: Localizable {
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
}
