//
//  Lightning
//
//  Created by Otto Suess on 12.09.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation
import SwiftBTC
import SwiftLnd

/// Includes all unsettled invoices.
public struct InvoiceEvent: Equatable, DateProvidingEvent {
    public let id: String
    public let memo: String?
    public let amount: Satoshi?
    public var date: Date {
        if invoice.state == .settled,
            let settleDate = invoice.settleDate {
            return settleDate
        } else {
            return invoice.date
        }
    }
    public let expiry: Date
    public let paymentRequest: String
    public let state: Invoice.State

    public var isExpired: Bool {
        return expiry < Date()
    }

    private var invoice: Invoice
}

extension InvoiceEvent {
    init(invoice: Invoice) {
        id = invoice.id
        memo = invoice.memo
        amount = invoice.amount
        expiry = invoice.expiry
        paymentRequest = invoice.paymentRequest
        state = invoice.state

        self.invoice = invoice
    }
}
