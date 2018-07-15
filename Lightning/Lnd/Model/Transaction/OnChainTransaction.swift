//
//  Lightning
//
//  Created by Otto Suess on 15.07.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import BTCUtil
import Foundation

public protocol OnChainTransaction: Transaction {
    var id: String { get }
    var amount: Satoshi { get }
    var date: Date { get }
    var fees: Satoshi? { get }
    var confirmations: Int { get }
    var destinationAddress: String { get }
}
