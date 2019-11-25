//
//  Library
//
//  Created by Christopher Pinski on 10/26/19.
//  Copyright © 2019 Zap. All rights reserved.
//

import Foundation

public enum PaymentFeeLimitPercentage: Int, Codable, CaseIterable {
    case none = 0
    case one = 1
    case three = 3
    case five = 5
    case ten = 10
}
