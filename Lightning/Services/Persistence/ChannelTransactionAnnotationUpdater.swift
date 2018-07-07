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
    let channelService: ChannelService
    let transactionService: TransactionService
    let updateCallback: (TransactionAnnotation, Transaction) -> Void
    
    public init(channelService: ChannelService, transactionService: TransactionService, updateCallback: @escaping (TransactionAnnotation, Transaction) -> Void) {
        self.channelService = channelService
        self.transactionService = transactionService
        self.updateCallback = updateCallback
        
        super.init()
        
        observeClosingTransactions()
        observeOpeningTransactions()
    }
    
    // MARK: - Closing
    
    private func observeClosingTransactions() {
        combineLatest(channelService.closed, transactionService.transactions)
            .observeNext { [weak self] arg in
                let (channelCloseSummaries, transactions) = arg
                self?.updateCloseChannelMemos(channelCloseSummaries: channelCloseSummaries, transactions: transactions)
            }
            .dispose(in: reactive.bag)
    }
    
    private func updateCloseChannelMemos(channelCloseSummaries: [ChannelCloseSummary], transactions: [Transaction]) {
        for transaction in transactions {
            guard let channelCloseSummary = channelCloseSummaries.first(where: { $0.closingTxHash == transaction.id }) else { continue }
            
            let annotation = TransactionAnnotation(isHidden: false, customMemo: nil, type: .closeChannelTransaction(remotePubKey: channelCloseSummary.remotePubKey, type: channelCloseSummary.closeType))
            updateCallback(annotation, transaction)
        }
    }

    // MARK: - Opening
    
    private func observeOpeningTransactions() {
        combineLatest(channelService.all, transactionService.transactions)
            .observeNext { [weak self] arg in
                let (channels, transactions) = arg
                self?.updateOpenChannelMemos(channels: channels, transactions: transactions)
            }
            .dispose(in: reactive.bag)
    }

    private func updateOpenChannelMemos(channels: [Channel], transactions: [Transaction]) {
        for transaction in transactions {
            // search for matching channel for funding transaction
            guard let channel = channels.first(where: { $0.channelPoint.fundingTxid == transaction.id }) else { continue }

            let annotation = TransactionAnnotation(isHidden: false, customMemo: nil, type: .openChannelTransaction(remotePubKey: channel.remotePubKey))
            updateCallback(annotation, transaction)
        }
    }
}
