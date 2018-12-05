//
//  Zap
//
//  Created by Otto Suess on 14.05.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation
import SwiftBTC

public struct Invoice: Equatable {
    public let id: String
    public let memo: String
    public let amount: Satoshi
    public let settled: Bool
    public let date: Date
    public let settleDate: Date?
    public let expiry: Date
    public let paymentRequest: String
}

extension Invoice {
    init(invoice: Lnrpc_Invoice) {
        id = invoice.rHash.hexadecimalString
        memo = invoice.memo
        settled = invoice.settled
        if settled {
            amount = Satoshi(invoice.amtPaidSat)
        } else {
            amount = Satoshi(invoice.value)
        }
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
