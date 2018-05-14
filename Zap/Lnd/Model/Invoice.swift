//
//  Zap
//
//  Created by Otto Suess on 14.05.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import BTCUtil
import Foundation

struct Invoice: Transaction, Equatable{
    let id: String
    let fees: Satoshi = 0
    let memo: String
    let amount: Satoshi
    let settled: Bool
    let date: Date
    let settleDate: Date?
    let expiry: Date
    let paymentRequest: String
}

extension Invoice {
    init(invoice: Lnrpc_Invoice) {
        id = invoice.rHash.hexString()
        memo = invoice.memo
        amount = Satoshi(value: invoice.value)
        settled = invoice.settled
        date = Date(timeIntervalSince1970: TimeInterval(invoice.creationDate))
        if invoice.settled {
            settleDate = Date(timeIntervalSince1970: TimeInterval(invoice.settleDate))
        } else {
            settleDate = nil
        }
        expiry = Date(timeIntervalSince1970: TimeInterval(invoice.creationDate + invoice.expiry))
        
        paymentRequest = invoice.paymentRequest
    }
}
