//
//  Zap
//
//  Created by Otto Suess on 14.05.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import BTCUtil
import Foundation

struct Invoice {
    let memo: String
    let value: Satoshi
    let settled: Bool
    let creationDate: Date
    let settleDate: Date?
    let expiry: Date
}

extension Invoice {
    init(invoice: Lnrpc_Invoice) {
        memo = invoice.memo
        value = Satoshi(value: invoice.value)
        settled = invoice.settled
        creationDate = Date(timeIntervalSince1970: TimeInterval(invoice.creationDate))
        if invoice.settled {
            settleDate = Date(timeIntervalSince1970: TimeInterval(invoice.settleDate))
        } else {
            settleDate = nil
        }
        expiry = Date(timeIntervalSince1970: TimeInterval(invoice.creationDate + invoice.expiry))
    }
}
