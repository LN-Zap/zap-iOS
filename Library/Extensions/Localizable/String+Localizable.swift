//
//  Zap
//
//  Created by Otto Suess on 05.04.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation

extension String: Localizable {
    public var localized: String {
        // swiftlint:disable:next localized_string
        return NSLocalizedString(self, bundle: Bundle.library, comment: "")
    }
}
