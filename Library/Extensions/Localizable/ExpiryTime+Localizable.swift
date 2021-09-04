//
//  Library
//
//  Created by Christopher Pinski on 10/7/19.
//  Copyright © 2019 Zap. All rights reserved.
//

import Foundation
import SwiftLnd

extension ExpiryTime: Localizable {
    public var localized: String {
        switch self {
        case .oneMinute:
            return L10n.ExpiryTime.oneMinute
        case .tenMinutes:
            return L10n.ExpiryTime.tenMinutes
        case .thirtyMinutes:
            return L10n.ExpiryTime.thirtyMinutes
        case .oneHour:
            return L10n.ExpiryTime.oneHour
        case .sixHours:
            return L10n.ExpiryTime.sixHours
        case .oneDay:
            return L10n.ExpiryTime.oneDay
        case .oneWeek:
            return L10n.ExpiryTime.oneWeek
        case .thirtyDays:
            return L10n.ExpiryTime.thirtyDays
        case .oneYear:
            return L10n.ExpiryTime.oneYear
        }
    }
}
