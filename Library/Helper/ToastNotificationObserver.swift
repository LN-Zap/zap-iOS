//
//  Library
//
//  Created by Otto Suess on 03.12.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Bond
import Foundation
import Lightning
import SwiftBTC
import SwiftLnd

final class ToastNotificationObserver: NSObject {

    func start() {
        NotificationCenter.default.reactive
            .notification(name: .receivedTransaction)
            .receive(on: DispatchQueue.main)
            .observeNext { notification in
                guard
                    let transaction = notification.userInfo?[LightningService.transactionNotificationName]
                    else { return }

                if let invoice = transaction as? Invoice {
                    ToastNotificationObserver.presentToast(satoshis: invoice.amount, memo: invoice.memo)
                } else if let onChainTransaction = transaction as? SwiftLnd.Transaction {
                    ToastNotificationObserver.presentToast(satoshis: onChainTransaction.amount)
                }

            }
            .dispose(in: reactive.bag)
    }

    private static func presentToast(satoshis: Satoshi, memo: String? = nil) {
        guard
            satoshis > 0,
            let amount = Settings.shared.primaryCurrency.value.format(satoshis: satoshis)
            else { return }

        if let memo = memo, !memo.isEmpty {
            Toast.presentSuccess(L10n.Toast.invoiceMemo(amount, memo))
        } else {
            Toast.presentSuccess(L10n.Toast.invoice(amount))
        }
    }
}
