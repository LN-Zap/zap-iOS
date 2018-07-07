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
    let updateCallback: (TransactionAnnotationType, Transaction) -> Void
    
    public init(channelService: ChannelService, transactionService: TransactionService, updateCallback: @escaping (TransactionAnnotationType, Transaction) -> Void) {
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
            
            let type = TransactionAnnotationType.closeChannelTransaction(remotePubKey: channelCloseSummary.remotePubKey, type: channelCloseSummary.closeType)
            updateCallback(type, transaction)
        }
    }

    // MARK: - Opening
    
    private func observeOpeningTransactions() {
        combineLatest(channelService.closed, channelService.all, transactionService.transactions)
            .observeNext { [weak self] arg in
                let (channelCloseSummaries, channels, transactions) = arg
                self?.updateOpenChannelMemos(channelCloseSummaries: channelCloseSummaries, channels: channels, transactions: transactions)
            }
            .dispose(in: reactive.bag)
    }

    private func updateOpenChannelMemos(channelCloseSummaries: [ChannelCloseSummary], channels: [Channel], transactions: [Transaction]) {
        for transaction in transactions {
            // search for matching channel for funding transaction
            if let channel = channels.first(where: { $0.channelPoint.fundingTxid == transaction.id }) {
                let type = TransactionAnnotationType.openChannelTransaction(remotePubKey: channel.remotePubKey)
                updateCallback(type, transaction)
            } else if let channelCloseSummary = channelCloseSummaries.first(where: { $0.channelPoint.fundingTxid == transaction.id }) {
                let type = TransactionAnnotationType.openChannelTransaction(remotePubKey: channelCloseSummary.remotePubKey)
                updateCallback(type, transaction)
            }
        }
    }
}
