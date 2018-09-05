//
//  Lightning
//
//  Created by Otto Suess on 08.07.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import BTCUtil
import Foundation

public struct LightningPayment: Transaction, Equatable {
    public let id: String
    public let amount: Satoshi
    public let date: Date
    public let fees: Satoshi
    public let paymentHash: String
}

extension LightningPayment {
    init(payment: Lnrpc_Payment) {
        id = payment.paymentHash
        amount = Satoshi(-payment.value)
        date = Date(timeIntervalSince1970: TimeInterval(payment.creationDate))
        fees = Satoshi(payment.fee)
        paymentHash = payment.paymentHash
    }
    
    init(paymentRequest: PaymentRequest, sendResponse: Lnrpc_SendResponse) {
        id = paymentRequest.paymentHash
        amount = -paymentRequest.amount
        date = paymentRequest.date
        fees = Satoshi(sendResponse.paymentRoute.totalFees)
        paymentHash = paymentRequest.paymentHash
    }
}
