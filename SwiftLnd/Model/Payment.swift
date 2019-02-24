//
//  Lightning
//
//  Created by Otto Suess on 08.07.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation
import LndRpc
import SwiftBTC

public struct Payment: Equatable {
    public let id: String
    public let amount: Satoshi
    public let date: Date
    public let fees: Satoshi
    public let paymentHash: String
    public let destination: String
}

extension Payment {
    init(payment: LNDPayment) {
        id = payment.paymentHash
        amount = Satoshi(-payment.valueSat)
        date = Date(timeIntervalSince1970: TimeInterval(payment.creationDate))
        fees = Satoshi(payment.fee)
        paymentHash = payment.paymentHash
        destination = payment.pathArray.compactMap { $0 as? String }.last ?? ""
    }

    init(paymentRequest: PaymentRequest, sendResponse: LNDSendResponse, amount: Satoshi? = nil) {
        id = paymentRequest.paymentHash
        if let amount = amount {
            self.amount = -amount
        } else {
            self.amount = -paymentRequest.amount
        }
        date = paymentRequest.date
        fees = Satoshi(sendResponse.paymentRoute.totalFeesMsat / 1000)
        paymentHash = paymentRequest.paymentHash
        destination = paymentRequest.destination
    }
}
