//
//  Lightning
//
//  Created by 0 on 02.04.19.
//  Copyright © 2019 Zap. All rights reserved.
//

import Bond
import Foundation
import Logger
import SwiftLnd

final class TransactionListUpdater: ListUpdater {
    private let api: LightningApiProtocol

    let transactions = MutableObservableArray<Transaction>()

    init(api: LightningApiProtocol) {
        self.api = api

        api.subscribeTransactions { [weak self] in
            if case .success(let transaction) = $0 {
                Logger.info("new transaction: \(transaction)")

                self?.transactions.append(transaction)
                NotificationCenter.default.post(name: .receivedTransaction, object: nil, userInfo: [LightningService.transactionNotificationName: transaction])
            }
        }
    }

    func update() {
        api.transactions { [weak self] in
            if case .success(let transactions) = $0 {
                self?.transactions.replace(with: transactions)
            }
        }
    }
}
