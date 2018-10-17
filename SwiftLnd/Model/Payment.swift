//
//  Lightning
//
//  Created by Otto Suess on 08.07.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation
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
    init(payment: Lnrpc_Payment) {
        id = payment.paymentHash
        amount = Satoshi(-payment.value)
        date = Date(timeIntervalSince1970: TimeInterval(payment.creationDate))
        fees = Satoshi(payment.fee)
        paymentHash = payment.paymentHash
        destination = payment.path.last ?? ""
    }
    
    init(paymentRequest: PaymentRequest, sendResponse: Lnrpc_SendResponse) {
        id = paymentRequest.paymentHash
        amount = -paymentRequest.amount
        date = paymentRequest.date
        fees = Satoshi(sendResponse.paymentRoute.totalFees)
        paymentHash = paymentRequest.paymentHash
        destination = paymentRequest.destination
    }
}
