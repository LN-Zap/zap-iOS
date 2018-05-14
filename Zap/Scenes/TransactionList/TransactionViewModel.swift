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
}

final class OnChainTransactionViewModel: NSObject {
    let onChainTransaction: BlockchainTransaction
    
    let displayText: Observable<String>
    let amount: Observable<Satoshi>
    let time: String

    init(onChainTransaction: BlockchainTransaction) {
        self.onChainTransaction = onChainTransaction
        
        if let alias = MemoryTransactionMetadataStore.instance.metadata(for: onChainTransaction)?.fundingChannelAlias {
            displayText = Observable("Open Channel: \(alias)")
            amount = Observable(-onChainTransaction.fees)
        } else {
            displayText = Observable(onChainTransaction.firstDestinationAddress)
            amount = Observable(onChainTransaction.amount)
        }
        
        time = DateFormatter.localizedString(from: onChainTransaction.date, dateStyle: .none, timeStyle: .short)
        
        super.init()
        
        NotificationCenter.default.reactive
            .notification(name: .TransactionMetadataChanged)
            .observeNext { [displayText, amount] notification in
                guard
                    let notificationTransaction = notification.userInfo?["transaction"] as? Transaction,
                    notificationTransaction as? BlockchainTransaction == onChainTransaction,
                    let metadata = notification.userInfo?["metadata"] as? TransactionMetadata,
                    let alias = metadata.fundingChannelAlias
                    else { return }
                
                amount.value = -notificationTransaction.fees
                displayText.value = "Open Channel: \(alias)"
            }
            .dispose(in: reactive.bag)
    }
}

final class LightningPaymentViewModel {
    let lightningPayment: Payment
    
    let displayText: String
    let amount: Satoshi
    let time: String

    init(lightningPayment: Payment) {
        self.lightningPayment = lightningPayment
        
        displayText = lightningPayment.paymentHash
        amount = lightningPayment.amount
        time = DateFormatter.localizedString(from: lightningPayment.date, dateStyle: .none, timeStyle: .short)
    }
}

final class LightningInvoiceViewModel {
    let lightningInvoice: Invoice
    
    let displayText: String
    let amount: Satoshi
    let time: String
    
    init(lightningInvoice: Invoice) {
        self.lightningInvoice = lightningInvoice
        
        if !lightningInvoice.memo.isEmpty {
            displayText = lightningInvoice.memo
        } else {
            displayText = lightningInvoice.paymentRequest
        }
        
        amount = lightningInvoice.amount
        time = DateFormatter.localizedString(from: lightningInvoice.date, dateStyle: .none, timeStyle: .short)
    }
}

final class TransactionViewModel {
    
    let type: TransactionType
    
    init(transaction: Transaction) {
        
        if let onChainTransaction = transaction as? BlockchainTransaction {
            type = .onChainTransaction(OnChainTransactionViewModel(onChainTransaction: onChainTransaction))
        } else if let lightningPayment = transaction as? Payment {
            type = .lightningPayment(LightningPaymentViewModel(lightningPayment: lightningPayment))
        } else if let lightningInvoice = transaction as? Invoice {
            type = .lightningInvoice(LightningInvoiceViewModel(lightningInvoice: lightningInvoice))
        } else {
            fatalError("type not implemented")
        }
    }
}

extension TransactionViewModel: Equatable {
    static func == (lhs: TransactionViewModel, rhs: TransactionViewModel) -> Bool {
        return lhs.type == rhs.type
    }
}
