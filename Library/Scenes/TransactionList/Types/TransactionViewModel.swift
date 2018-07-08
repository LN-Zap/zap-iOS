//
//  Zap
//
//  Created by Otto Suess on 16.05.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Bond
import BTCUtil
import Foundation
import Lightning

enum TransactionIcon {
    case onChain
    case lightningPayment
    case settledInvoice
    case unsettledInvoice
    case expiredInvoice
    case openChannel
    case closeChannel
    case unconfirmed
    
    var image: UIImage? {
        switch self {
        case .onChain:
            return imageNamed("icon_transaction_onchain")
        case .lightningPayment:
            return imageNamed("icon_transaction_lightning")
        case .settledInvoice:
            return imageNamed("icon_transaction_invoice")
        case .unsettledInvoice:
            return imageNamed("icon_transaction_invoice_pending")
        case .expiredInvoice:
            return imageNamed("icon_transaction_invoice")
        case .openChannel:
            return imageNamed("icon_transaction_open_channel")
        case .unconfirmed:
            return imageNamed("icon_transaction_unconfirmed")
        case .closeChannel:
            return imageNamed("icon_transaction_close_channel")
        }
    }
    
    private func imageNamed(_ name: String) -> UIImage? {
        return UIImage(named: name, in: Bundle.shared, compatibleWith: nil)
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
        return (object as? TransactionViewModel)?.transaction.isEqual(to: transaction) ?? false
    }
    
    static func instance(for transaction: Transaction, annotation: TransactionAnnotation, aliasStore: ChannelAliasStore) -> TransactionViewModel {
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
    
    func matchesFilterSettings(_ filterSettings: FilterSettings) -> Bool {
        let isMatchingTransactionType = (transaction is OnChainTransaction && filterSettings.displayOnChainTransactions)
            || (transaction is LightningPayment && filterSettings.displayLightningPayments)
            || (transaction is LightningInvoice && filterSettings.displayLightningInvoices)
        
        return (!annotation.value.isHidden || filterSettings.displayArchivedTransactions) && isMatchingTransactionType
    }
    
    func matchesSearchString(_ string: String?) -> Bool {
        guard
            let string = string?.trimmingCharacters(in: .whitespacesAndNewlines).localizedLowercase,
            !string.isEmpty
            else { return true }
        
        return annotation.value.customMemo?.localizedLowercase.contains(string) == true
            || displayText.value.localizedLowercase.contains(string)
            || id.localizedLowercase.contains(string)
    }
}
