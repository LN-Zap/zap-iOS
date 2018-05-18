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
    
    init(viewModel: ViewModel, transactionStore: TransactionStore) {
        super.init()
        
        combineLatest(viewModel.channels.all, viewModel.transactions)
            .observeNext { [weak self] arg in
                let (channels, transactions) = arg
                self?.updateMemos(in: transactionStore, channels: channels, transactions: transactions)
            }
            .dispose(in: reactive.bag)
    }

    // TODO: don't use customMemo, use own field
    func updateMemos(in transactionStore: TransactionStore, channels: [Channel], transactions: [TransactionViewModel]) {
        for transaction in transactions /*where transaction.annotation.value.customMemo == nil*/ {
            // search for matching channel for funding transaction
            guard let channel = channels.first(where: { $0.channelPoint.hasPrefix(transaction.id) }) else { continue }

            let annotation = TransactionAnnotation(isHidden: false, customMemo: nil, type: .openChannelTransaction(channel.remotePubKey))
            transactionStore.updateAnnotation(annotation, for: transaction)            
        }
    }
}
