//
//  Lightning
//
//  Created by Otto Suess on 10.09.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import BTCUtil
import Foundation
import SwiftLnd

final class DatabaseUpdater {
    
    func channelsUpdated() {
        
    }
    
    func closedChannelsUpdated() {
        
    }
    
    static func addTransactions(_ transactions: [OnChainPaymentEvent]) {
        // update unconfirmed transaction block height
        do {
            let txHashes = transactions.map { $0.txHash }
            let unconfirmedTransactions = try OnChainPaymentEvent.unconfirmedEvents(for: txHashes)
            
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
        let transactionEvent = OnChainPaymentEvent(
            txHash: txId,
            memo: memo,
            amount: amount,
            fee: 0,
            date: Date(),
            destinationAddresses: [destinationAddress],
            blockHeight: nil)
        
        do {
            try transactionEvent.insert()
            print("❤️ added unconfirmed transaction")
        } catch {
            print("⚠️", error)
        }
    }
    
    func addFailedPayment() {
        
    }
    
    func addInvoices() {
        
    }
    
    func addPayments() {
        
    }
}
