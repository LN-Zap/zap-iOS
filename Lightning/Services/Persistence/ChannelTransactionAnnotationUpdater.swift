//
//  Zap
//
//  Created by Otto Suess on 07.04.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Bond
import Foundation
import ReactiveKit

public final class ChannelTransactionAnnotationUpdater: NSObject {
    public init(channelService: ChannelService, transactionService: TransactionService, updateCallback: @escaping (TransactionAnnotation, Transaction) -> Void) {
        super.init()

        combineLatest(channelService.all, transactionService.transactions)
            .observeNext { [weak self] arg in
                let (channels, transactions) = arg
                self?.updateMemos(channels: channels, transactions: transactions, updateCallback: updateCallback)
            }
            .dispose(in: reactive.bag)
    }

    private func updateMemos(channels: [Channel], transactions: [Transaction], updateCallback: (TransactionAnnotation, Transaction) -> Void) {
        for transaction in transactions {
            // search for matching channel for funding transaction
            guard let channel = channels.first(where: { $0.channelPoint.fundingTxid == transaction.id }) else { continue }

            let annotation = TransactionAnnotation(isHidden: false, customMemo: nil, type: .openChannelTransaction(channel.remotePubKey))
            updateCallback(annotation, transaction)
        }
    }
}
