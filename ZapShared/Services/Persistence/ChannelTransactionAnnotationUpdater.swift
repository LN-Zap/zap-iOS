//
//  Zap
//
//  Created by Otto Suess on 07.04.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Bond
import Foundation
import ReactiveKit

final class ChannelTransactionAnnotationUpdater: NSObject {
    
    init(channelService: ChannelService, transactionListViewModel: TransactionListViewModel) {
        super.init()

        combineLatest(channelService.all, transactionListViewModel.sections)
            .observeNext { [weak self] arg in
                let (channels, transactionSections) = arg
                let transactions = transactionSections.source.sections.flatMap {
                    $0.items
                }
                
                self?.updateMemos(in: transactionListViewModel, channels: channels, transactions: transactions)
            }
            .dispose(in: reactive.bag)
    }

    func updateMemos(in transactionListViewModel: TransactionListViewModel, channels: [Channel], transactions: [TransactionViewModel]) {
        for transaction in transactions where transaction.annotation.value.customMemo == nil {
            // search for matching channel for funding transaction
            guard let channel = channels.first(where: { $0.channelPoint.hasPrefix(transaction.id) }) else { continue }

            let annotation = TransactionAnnotation(isHidden: false, customMemo: nil, type: .openChannelTransaction(channel.remotePubKey))
            transactionListViewModel.updateAnnotation(annotation, for: transaction)
        }
    }
}
