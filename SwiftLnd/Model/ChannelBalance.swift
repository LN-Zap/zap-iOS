//
//  SwiftLnd
//
//  Created by 0 on 08.04.19.
//  Copyright © 2019 Zap. All rights reserved.
//

import Foundation
import SwiftBTC

public struct ChannelBalance {
    public let balance: Satoshi
    public let pendingOpenBalance: Satoshi
}

extension ChannelBalance {
    init(channelBalance: Lnrpc_ChannelBalanceResponse) {
        balance = Satoshi(channelBalance.balance)
        pendingOpenBalance = Satoshi(channelBalance.pendingOpenBalance)
    }
}
