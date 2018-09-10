//
//  Lightning
//
//  Created by Otto Suess on 10.09.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation
import SwiftLnd

/// Does influence the balance of the user's wallet because a fee is payed.
struct openChannelEvent {
    let transaction: Transaction
    let remotePubKey: String
    let fee: Satoshi
}

/// Does influence the balance of the user's wallet because a fee is payed.
struct closeChannelEvent {
    let transaction: Transaction
    let remotePubKey: String
    let type: CloseType
    let fee: Satoshi
}

/// Includes all invoices, settled and unsettled.
struct createInvoiceEvent {
    let invoice: Invoice
}

/// Gets created when a payment request fails to complete.
struct failedPaymentEvent {
    let paymentRequest: PaymentRequest
    let date: Date
}

/*
 This is any event that transfers bitcoin from one wallet to another.
 Includes transactions, except those resulting from opening or closing channels.
 Includes all Payments.
 Inlcudes invoices that have been settled.
 */
struct paymentEvent {
    let id: String
    let totalValue: Satoshi // amount + optional fees
    let date: Date
}
