//
//  BTCUtil
//
//  Created by Otto Suess on 30.03.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import Foundation

public extension Decimal {
    public func absoluteValue() -> Decimal {
        if self < 0 {
            return self * -1
        } else {
            return self
        }
    }
    
    func multiplying(byPowerOf10 power: Int) -> Decimal {
        var result = Decimal()
        var mutableSelf = self
        NSDecimalMultiplyByPowerOf10(&result, &mutableSelf, Int16(power), .bankers)
        return result
    }
}
