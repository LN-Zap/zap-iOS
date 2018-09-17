//
//  Lightning
//
//  Created by Otto Suess on 10.09.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import BTCUtil
import Foundation
import SQLite
import SwiftLnd

enum DatabaseUpdater {
    static func channelsUpdated(_ channels: [Channel]) {
        do {
            for channel in channels {
                guard let blockHeight = channel.blockHeight else { continue }
                let openEvent = ChannelEvent(
                    txHash: channel.channelPoint.fundingTxid,
                    node: ConnectedNode(pubKey: channel.remotePubKey, alias: nil, color: nil),
                    blockHeight: blockHeight,
                    type: .open,
                    fee: nil
                )
                try openEvent.insert()
            }
        } catch {
            print("🤷🏻‍♂️ error", error)
        }
    }
    
    static func closedChannelsUpdated(_ channelCloseSummaries: [ChannelCloseSummary]) {
        do {
            let closingTxIds = channelCloseSummaries.map { $0.closingTxHash }
            try markTxIdsAsChannelRelated(txIds: closingTxIds)
            
            let openingTxIds = channelCloseSummaries.map { $0.channelPoint.fundingTxid }
            try markTxIdsAsChannelRelated(txIds: openingTxIds)
            
            for channelCloseSummary in channelCloseSummaries {
                let closeEvent = ChannelEvent(
                    txHash: channelCloseSummary.closingTxHash,
                    node: ConnectedNode(pubKey: channelCloseSummary.remotePubKey, alias: nil, color: nil),
                    blockHeight: channelCloseSummary.closeHeight,
                    type: ChannelEvent.ChanneEventType(closeType: channelCloseSummary.closeType),
                    fee: nil
                )
                try closeEvent.insert()
                
                if channelCloseSummary.openHeight > 0 { // i guess chanID is 0 for channels opened by remote nodes
                    let openEvent = ChannelEvent(
                        txHash: channelCloseSummary.channelPoint.fundingTxid,
                        node: ConnectedNode(pubKey: channelCloseSummary.remotePubKey, alias: nil, color: nil),
                        blockHeight: channelCloseSummary.openHeight,
                        type: .open,
                        fee: nil
                    )
                    try openEvent.insert()
                }
            }
            
        } catch {
            print("🤷🏻‍♂️ error", error)
        }
    }
    
    private static func markTxIdsAsChannelRelated(txIds: [String]) throws {
        let query = TransactionEvent.table
            .filter(TransactionEvent.Column.channelRelated == nil)
            .filter(txIds.contains(TransactionEvent.Column.txHash))
        try SQLiteDataStore.shared.database.run(query.update(TransactionEvent.Column.channelRelated <- true))
    }
    
    static func addTransactions(_ transactions: [TransactionEvent]) {
        // update unconfirmed transaction block height
        do {
            let txHashes = transactions.map { $0.txHash }
            let unconfirmedTransactions = try TransactionEvent.unconfirmedEvents(for: txHashes)
            
            for unconfirmedTransaction in unconfirmedTransactions {
                guard let transaction = transactions.first(where: { $0.txHash == unconfirmedTransaction.txHash }) else { continue }
                _ = try transaction.updateBlockHeight()
                print("❤️ updated unconfirmed transaction")
            }
        } catch {
            print("⚠️ unconf:", error)
        }
    
        // add unknown transactions, fail on first error
        do {
            for transaction in transactions {
                try transaction.insert()
            }
        } catch {
            print("⚠️ add:", error)
        }
    }
    
    static func addUnconfirmedTransaction(txId: String, amount: Satoshi, memo: String?, destinationAddress: BitcoinAddress) {
        let transactionEvent = TransactionEvent(
            txHash: txId,
            memo: memo,
            amount: amount,
            fee: 0,
            date: Date(),
            destinationAddresses: [destinationAddress],
            blockHeight: nil,
            channelRelated: true)
        
        do {
            try transactionEvent.insert()
            print("❤️ added unconfirmed transaction")
        } catch {
            print("⚠️", error)
        }
    }
    
    static func addInvoices(_ invoices: [Invoice]) {
        do {
            for invoice in invoices {
                let createInvoiceEvent = CreateInvoiceEvent(
                    id: invoice.id,
                    memo: invoice.memo,
                    amount: invoice.amount,
                    date: invoice.date,
                    expiry: invoice.expiry,
                    paymentRequest: invoice.paymentRequest)
                
                try createInvoiceEvent.insert()
                
                if invoice.settled {
                    let paymentEvent = LightningPaymentEvent(
                        paymentHash: invoice.id,
                        memo: invoice.memo,
                        amount: invoice.amount,
                        fee: 0,
                        date: invoice.date)
                    try paymentEvent.insert()
                }
            }
        } catch {
            print("⚠️", error)
        }
    }
    
    static func addPayments(_ payments: [Payment]) {
        do {
            for payment in payments {
                let paymentEvent = LightningPaymentEvent(
                    paymentHash: payment.paymentHash,
                    memo: nil,
                    amount: payment.amount,
                    fee: payment.fees,
                    date: payment.date)
                try paymentEvent.insert()
            }
        } catch {
            print("⚠️", error)
        }
    }
}
