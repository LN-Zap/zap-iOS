//
//  Lightning
//
//  Created by Otto Suess on 12.09.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation
import SwiftBTC
import SwiftLnd

/*
 Includes all Payments (sent lightning transactions).
 Inlcudes invoices that have been settled (received lightning transactions).
 */
public struct LightningPaymentEvent: Equatable, DateProvidingEvent {
    public let paymentHash: String
    public let amount: Satoshi // amount + optional fees
    public let fee: Satoshi
    public let date: Date
    public let node: LightningNode
    public let preimage: String
}

extension LightningPaymentEvent {
    init(payment: Payment) {
        paymentHash = payment.paymentHash
        amount = payment.amount
        fee = payment.fees
        date = payment.date
        node = LightningNode(pubKey: payment.destination, alias: nil, color: nil)
        preimage = payment.preimage
    }
}
