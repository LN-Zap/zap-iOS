//
//  SwiftLnd
//
//  Created by Otto Suess on 25.10.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation
import SwiftBTC

public struct Route {
    public let totalFees: Satoshi
    public let totalAmount: Satoshi
}

extension Route {
    init(route: Lnrpc_Route) {
        totalFees = Satoshi(route.totalFees)
        totalAmount = Satoshi(route.totalAmt)
    }
}
