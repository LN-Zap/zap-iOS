//
//  Library
//
//  Created by Christopher Pinski on 10/26/19.
//  Copyright © 2019 Zap. All rights reserved.
//

import Foundation
import SwiftLnd

extension PaymentFeeLimitPercentage: Localizable {
    public var localized: String {
        switch self {
        case .zero:
            return L10n.PaymentFeeLimitPercentage.none
        default:
            return "\(self.rawValue)%"
        }
    }
}
