//
//  SwiftLnd
//
//  Created by Christopher Pinski on 10/7/19.
//  Copyright © 2019 Zap. All rights reserved.
//

import Foundation

public enum ExpiryTime: Int, Codable, CaseIterable {
    case oneMinute = 60
    case tenMinutes = 600 // 60 * 10
    case thirtyMinutes = 1800 // 60 * 30
    case oneHour = 3600 // 60 * 60
    case sixHours = 21600 // 60 * 60 * 6
    case oneDay = 86400 // 60 * 60 * 24
    case oneWeek = 604800 // 60 * 60 * 24 * 7
    case thirtyDays = 2592000 // 60 * 60 * 24 * 30
    case oneYear = 31536000 // 60 * 60 * 24 * 365
}
