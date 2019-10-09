//
//  SwiftLnd
//
//  Created by Christopher Pinski on 10/7/19.
//  Copyright © 2019 Zap. All rights reserved.
//

import Foundation

public enum ExpiryTime: Int64, Codable, CaseIterable {
    case oneMinute = 60
    case tenMinutes = 600
    case thirtyMinutes = 1800
    case oneHour = 3600
    case sixHours = 21600
    case oneDay = 86400
    case oneWeek = 604800
    case thirtyDays = 2592000
    case oneYear = 31536000
}
