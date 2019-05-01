//
//  SwiftLnd
//
//  Created by 0 on 08.04.19.
//  Copyright © 2019 Zap. All rights reserved.
//

import Foundation
import SwiftBTC

public struct WalletBalance {
    public let confirmedBalance: Satoshi
    public let unconfirmedBalance: Satoshi
}

extension WalletBalance {
    init(walletBalance: Lnrpc_WalletBalanceResponse) {
        confirmedBalance = Satoshi(walletBalance.confirmedBalance)
        unconfirmedBalance = Satoshi(walletBalance.unconfirmedBalance)
    }
}
