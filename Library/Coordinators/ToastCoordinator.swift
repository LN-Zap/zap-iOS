//
//  Library
//
//  Created by Otto Suess on 03.12.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Bond
import Foundation
import Lightning
import SwiftLnd

final class ToastCoordinator: NSObject {
    
    func start() {
        NotificationCenter.default.reactive
            .notification(name: .receivedTransaction)
            .observeOn(DispatchQueue.main)
            .observeNext { notification in
                guard
                    let transaction = notification.userInfo?[LightningService.transactionNotificationName]
                    else { return }
                
                if let invoice = transaction as? Invoice {
                    ToastCoordinator.presentToast(for: invoice)
                } else if let onChainTransaction = transaction as? SwiftLnd.Transaction {
                    ToastCoordinator.presentToast(for: onChainTransaction)
                }
                
            }
            .dispose(in: reactive.bag)
    }
    
    private static func presentToast(for invoice: Invoice) {
        guard let amount = Settings.shared.primaryCurrency.value.format(satoshis: invoice.amount) else { return }
        
        if invoice.memo.isEmpty {
            Toast.presentSuccess(L10n.Toast.invoice(amount))
        } else {
            Toast.presentSuccess(L10n.Toast.invoiceMemo(amount, invoice.memo))
        }
    }
    
    private static func presentToast(for transaction: Transaction) {
        guard let amount = Settings.shared.primaryCurrency.value.format(satoshis: transaction.amount) else { return }

        Toast.presentSuccess(L10n.Toast.invoice(amount))
    }
}
