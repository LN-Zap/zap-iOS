//
//  Zap
//
//  Created by Otto Suess on 16.05.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Bond
import BTCUtil
import Foundation

enum TransactionIcon {
    case onChain
    case lightningPayment
    case settledInvoice
    case unsettledInvoice
    case expiredInvoice
    case openChannel
    case unconfirmed
    
    var image: UIImage {
        switch self {
        case .onChain:
            return #imageLiteral(resourceName: "icon_transaction_onchain")
        case .lightningPayment:
            return #imageLiteral(resourceName: "icon_transaction_lightning")
        case .settledInvoice:
            return #imageLiteral(resourceName: "icon_transaction_invoice")
        case .unsettledInvoice:
            return #imageLiteral(resourceName: "icon_transaction_invoice_pending")
        case .expiredInvoice:
            return #imageLiteral(resourceName: "icon_transaction_invoice")
        case .openChannel:
            return #imageLiteral(resourceName: "icon_transaction_openchannel")
        case .unconfirmed:
            return #imageLiteral(resourceName: "icon_transaction_unconfirmed")
        }
    }
}

class TransactionViewModel: NSObject {
    var id: String {
        return transaction.id
    }
    var date: Date {
        return transaction.date
    }
    
    let annotation: Observable<TransactionAnnotation>
    let displayText: Observable<String>
    let amount: Observable<Satoshi?>
    let icon: Observable<TransactionIcon>
    let transaction: Transaction
    
    init(transaction: Transaction, annotation: TransactionAnnotation, displayText: String, amount: Satoshi?, icon: TransactionIcon) {
        self.annotation = Observable(annotation)
        self.icon = Observable(icon)
        self.displayText = Observable(displayText)
        self.amount = Observable(amount)
        self.transaction = transaction
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        return id == (object as? TransactionViewModel)?.id
    }

    static func instance(for transaction: Transaction, transactionStore: TransactionAnnotationStore, aliasStore: ChannelAliasStore) -> TransactionViewModel {
        let annotation = transactionStore.annotation(for: transaction)
        
        if let transaction = transaction as? OnChainTransaction {
            return OnChainTransactionViewModel(onChainTransaction: transaction, annotation: annotation, aliasStore: aliasStore)
        } else if let transaction = transaction as? LightningPayment {
            return LightningPaymentViewModel(lightningPayment: transaction, annotation: annotation)
        } else if let transaction = transaction as? LightningInvoice {
            return LightningInvoiceViewModel(lightningInvoice: transaction, annotation: annotation)
        } else {
            fatalError("type not implemented")
        }
    }
}
