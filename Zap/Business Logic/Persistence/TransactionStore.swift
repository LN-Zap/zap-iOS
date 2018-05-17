//
//  Zap
//
//  Created by Otto Suess on 15.05.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Bond
import Foundation

final class TransactionStore {
    let transactions: Observable<[TransactionViewModel]>
    var annotations = [String: TransactionAnnotation]()
    
    init() {
        transactions = Observable([])
        
        loadAnnotations()
    }
    
    func update(transactions newTransactions: [Transaction]) {
        var viewModels = [TransactionViewModel]()
        for transaction in newTransactions where !exists(transaction) {
            let viewModel = transcactionViewModel(for: transaction)
            if !viewModel.annotation.value.isHidden {
                viewModels.append(viewModel)
            }
        }
        transactions.value += viewModels
    }
    
    func setMemo(_ memo: String, forPaymentHash paymentHash: String) {
        annotations[paymentHash] = TransactionAnnotation(isHidden: false, customMemo: memo)
        
        saveAnnotations()
    }
    
    func updateAnnotation(_ annotation: TransactionAnnotation, for transactionViewModel: TransactionViewModel) {
        annotations[transactionViewModel.id] = annotation
        
        if annotation.isHidden,
            let index = transactions.value.index(where: {
                areTransactionsEqual(lhs: $0, rhs: transactionViewModel)
            }) {
            
            var newTransactions = transactions.value
            newTransactions.remove(at: index)
            transactions.value = newTransactions
        } else {
            transactionViewModel.annotation.value = annotation
        }
        
        saveAnnotations()
    }
    
    private var plistUrl: URL? {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("annotations.plist")
    }
    
    private func saveAnnotations() {
        guard
            let encoded = try? PropertyListEncoder().encode(annotations),
            let url = plistUrl
            else { return }
        try? encoded.write(to: url)
    }
    
    private func loadAnnotations() {
        guard
            let url = plistUrl,
            let data = try? Data(contentsOf: url),
            let decoded = try? PropertyListDecoder().decode(Dictionary<String, TransactionAnnotation>.self, from: data) else { return }
        annotations = decoded
    }
    
    // MARK: - Private, refactor this shit
    
    private func areTransactionsEqual(lhs: TransactionViewModel, rhs: TransactionViewModel) -> Bool {
        if let lhs = lhs as? OnChainTransactionViewModel,
            (rhs as? OnChainTransactionViewModel)?.onChainTransaction == lhs.onChainTransaction {
            return true
        } else if let lhs = lhs as? LightningPaymentViewModel,
            (rhs as? LightningPaymentViewModel)?.lightningPayment == lhs.lightningPayment {
            return true
        } else if let lhs = lhs as? LightningInvoiceViewModel,
            (rhs as? LightningInvoiceViewModel)?.lightningInvoice == lhs.lightningInvoice {
            return true
        }
        
        return false
    }
    
    private func exists(_ transaction: Transaction) -> Bool {
        for existingTransaction in transactions.value {
            if let existingTransaction = existingTransaction as? OnChainTransactionViewModel,
                (transaction as? OnChainTransaction) == existingTransaction.onChainTransaction {
                return true
            } else if let existingTransaction = existingTransaction as? LightningPaymentViewModel,
                (transaction as? LightningPayment) == existingTransaction.lightningPayment {
                return true
            } else if let existingTransaction = existingTransaction as? LightningInvoiceViewModel,
                (transaction as? LightningInvoice) == existingTransaction.lightningInvoice {
                return true
            }
        }
        return false
    }
    
    private func transcactionViewModel(for transaction: Transaction) -> TransactionViewModel {
        let annotation = annotations[transaction.id] ?? TransactionAnnotation()
        
        if let transaction = transaction as? OnChainTransaction {
            return OnChainTransactionViewModel(onChainTransaction: transaction, annotation: annotation)
        } else if let transaction = transaction as? LightningPayment {
            return LightningPaymentViewModel(lightningPayment: transaction, annotation: annotation)
        } else if let transaction = transaction as? LightningInvoice {
            return LightningInvoiceViewModel(lightningInvoice: transaction, annotation: annotation)
        } else {
            fatalError("type not implemented")
        }
    }
}
