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
    static func addTransactions(_ transactions: [OnChainConfirmedTransaction]) {
        let transactions = transactions.map { TransactionEvent(transaction: $0) }
        
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
            print("⚠️ `\(#function)`:", error)
        }
    
        // add unknown transactions, fail on first error
        do {
            for transaction in transactions {
                try transaction.insert()
            }
        } catch {
            print("⚠️ `\(#function)`:", error)
        }
    }
    
    static func addInvoices(_ invoices: [Invoice]) {
        do {
            for invoice in invoices {
                let createInvoiceEvent = CreateInvoiceEvent(invoice: invoice)
                try createInvoiceEvent.insert()
                
                if invoice.settled {
                    let paymentEvent = LightningPaymentEvent(invoice: invoice)
                    try paymentEvent.insert()
                }
            }
        } catch {
            print("⚠️ `\(#function)`:", error)
        }
    }
    
    static func addPayments(_ payments: [Payment]) {
        do {
            for payment in payments {
                let paymentEvent = LightningPaymentEvent(payment: payment, memo: nil)
                try paymentEvent.insert()
            }
        } catch {
            print("⚠️ `\(#function)`:", error)
        }
    }
}
