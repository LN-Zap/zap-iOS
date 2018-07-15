//
//  Zap
//
//  Created by Otto Suess on 14.05.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import BTCUtil
import Foundation

public struct LightningInvoice: Transaction, Equatable {
    public let id: String
    public let fees: Satoshi = 0
    public let memo: String
    public let amount: Satoshi
    public let settled: Bool
    public let date: Date
    public let settleDate: Date?
    public let expiry: Date
    public let paymentRequest: String
}

extension LightningInvoice {
    init(invoice: Lnrpc_Invoice) {
        id = invoice.rHash.hexString()
        memo = invoice.memo
        amount = Satoshi(invoice.value)
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
