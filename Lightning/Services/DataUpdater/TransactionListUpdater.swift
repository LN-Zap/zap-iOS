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

                self?.appendOrReplace(transaction)
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

    private func appendOrReplace(_ transaction: Transaction) {
        transactions.batchUpdate {
            for (index, item) in $0.array.enumerated() where item.id == transaction.id {
                $0.remove(at: index)
                break
            }
            $0.append(transaction)
        }
    }
}
