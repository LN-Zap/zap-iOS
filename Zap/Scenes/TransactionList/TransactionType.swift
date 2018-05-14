//
//  Zap
//
//  Created by Otto Suess on 06.04.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Bond
import BTCUtil
import Foundation
import ReactiveKit

enum TransactionType: Equatable {
    case onChainTransaction(OnChainTransactionViewModel)
    case lightningPayment(LightningPaymentViewModel)
    case lightningInvoice(LightningInvoiceViewModel)
    
    static func == (lhs: TransactionType, rhs: TransactionType) -> Bool {
        switch (lhs, rhs) {
        case let (.onChainTransaction(lhsVM), .onChainTransaction(rhsVM)):
            return lhsVM.onChainTransaction == rhsVM.onChainTransaction
        case let (.lightningPayment(lhsVM), .lightningPayment(rhsVM)):
            return lhsVM.lightningPayment == rhsVM.lightningPayment
        case let (.lightningInvoice(lhsVM), .lightningInvoice(rhsVM)):
            return lhsVM.lightningInvoice == rhsVM.lightningInvoice
        default:
            return false
        }
    }
    
    init(transaction: Transaction) {
        if let onChainTransaction = transaction as? BlockchainTransaction {
            self = .onChainTransaction(OnChainTransactionViewModel(onChainTransaction: onChainTransaction))
        } else if let lightningPayment = transaction as? Payment {
            self = .lightningPayment(LightningPaymentViewModel(lightningPayment: lightningPayment))
        } else if let lightningInvoice = transaction as? Invoice {
            self = .lightningInvoice(LightningInvoiceViewModel(lightningInvoice: lightningInvoice))
        } else {
            fatalError("type not implemented")
        }
    }
}
