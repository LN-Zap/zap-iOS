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
    
    var transactionViewModel: TransactionViewModel {
        switch self {
        case .onChainTransaction(let viewModel):
            return viewModel
        case .lightningPayment(let viewModel):
            return viewModel
        case .lightningInvoice(let viewModel):
            return viewModel
        }
    }
    
    init(transactionViewModel: TransactionViewModel) {
        if let viewModel = transactionViewModel as? OnChainTransactionViewModel {
            self = .onChainTransaction(viewModel)
        } else if let viewModel = transactionViewModel as? LightningPaymentViewModel {
            self = .lightningPayment(viewModel)
        } else if let viewModel = transactionViewModel as? LightningInvoiceViewModel {
            self = .lightningInvoice(viewModel)
        } else {
            fatalError("type not implemented")
        }
    }
}
