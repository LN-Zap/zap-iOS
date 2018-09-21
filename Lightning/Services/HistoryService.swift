//
//  Lightning
//
//  Created by Otto Suess on 18.09.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import BTCUtil
import Foundation
import SQLite
import SwiftLnd

public extension Notification.Name {
    public static let historyDidChange = Notification.Name(rawValue: "historyDidChange")
}

public final class HistoryService {
    private let api: LightningApiProtocol
    private let channelService: ChannelService
    private let persistance: Persistance
    
    public var events = [HistoryEventType]()
    public var userTransaction = [PlottableEvent]()
    
    init(api: LightningApiProtocol, channelService: ChannelService, persistance: Persistance) {
        self.api = api
        self.channelService = channelService
        self.persistance = persistance
    }
    
    /// Load all transactions from db
    private func updateEvents() {
        do {
            let database = try persistance.connection()
            
            var dateProvidingEvents = [DateProvidingEvent]()
            let payments = try TransactionEvent.payments(database: database)
            let lightningPayments = try LightningPaymentEvent.events(database: database)
            
            dateProvidingEvents.append(contentsOf: payments)
            dateProvidingEvents.append(contentsOf: lightningPayments)
            dateProvidingEvents.append(contentsOf: try CreateInvoiceEvent.events(database: database))
            dateProvidingEvents.append(contentsOf: try FailedPaymentEvent.events(database: database))
            
            let dateEstimator = DateEstimator(database: database)
            let channelEvents = try ChannelEvent.events(database: database).map { (channelEvent: ChannelEvent) -> DateWrappedChannelEvent in
                dateEstimator.wrapChannelEvent(channelEvent)
            }
            
            dateProvidingEvents.append(contentsOf: channelEvents)
            
            events = dateProvidingEvents.map(HistoryEventType.create)
            userTransaction = payments as [PlottableEvent] + lightningPayments as [PlottableEvent]
            
            sendChangeNotification()
        } catch {
            print("⚠️ `\(#function)`:", error)
        }
    }
    
    /// Write new transactions in db
    public func update() {
        updateEvents()
        
        let taskGroup = DispatchGroup()

        taskGroup.enter()
        api.transactions { [addTransactions] in
            guard let transactions = $0.value else { return }
            addTransactions(transactions)
            taskGroup.leave()
        }
        
        taskGroup.enter()
        api.payments { [addPayments] in
            guard let payments = $0.value else { return }
            addPayments(payments)
            taskGroup.leave()
        }
        
        taskGroup.enter()
        api.invoices { [addInvoices] in
            guard let invoices = $0.value else { return }
            addInvoices(invoices)
            taskGroup.leave()
        }
        
        taskGroup.notify(queue: .main, work: DispatchWorkItem(block: { [weak self] in
            self?.updateEvents()
        }))
    }
    
    func addFailedPaymentEvent(paymentRequest: PaymentRequest, amount: Satoshi) {
        do {
            let failedEvent = FailedPaymentEvent(paymentRequest: paymentRequest, amount: amount)
            try failedEvent.insert(database: persistance.connection())
            events.insert(.failedPaymentEvent(failedEvent), at: 0)
            sendChangeNotification()
        } catch {
            print(error)
        }
    }
    
    func addPaymentEvent(payment: Payment, memo: String?) {
        do {
            let paymentEvent = LightningPaymentEvent(payment: payment, memo: memo)
            try paymentEvent.insert(database: persistance.connection())
            events.insert(.lightningPaymentEvent(paymentEvent), at: 0)
            sendChangeNotification()
        } catch {
            print(error)
        }
    }
    
    func addUnconfirmedTransaction(txId: String, amount: Satoshi, memo: String?, destinationAddress: BitcoinAddress) {
        do {
            let transactionEvent = TransactionEvent(txId: txId, amount: amount, memo: memo, destinationAddress: destinationAddress)
            try transactionEvent.insert(database: persistance.connection())
            events.insert(.transactionEvent(transactionEvent), at: 0)
            sendChangeNotification()
        } catch {
            print(error)
        }
    }
    
    func addedTransaction(_ transaction: OnChainConfirmedTransaction) {
        addTransactions([transaction])
        let transactionEvent = TransactionEvent(transaction: transaction)
        events.insert(.transactionEvent(transactionEvent), at: 0)
        sendChangeNotification()
    }
    
    func addedInvoice(_ invoice: Invoice) {
        addInvoices([invoice])
        let invoiceEvent = CreateInvoiceEvent(invoice: invoice)
        events.insert(.createInvoiceEvent(invoiceEvent), at: 0)
        sendChangeNotification()
    }
    
    private func sendChangeNotification() {
        NotificationCenter.default.post(name: .historyDidChange, object: nil)
    }
}

// MARK: - Persistance
extension HistoryService {
    private func addTransactions(_ transactions: [OnChainConfirmedTransaction]) {
        let transactions = transactions.map { TransactionEvent(transaction: $0) }
        
        // update unconfirmed transaction block height
        do {
            let txHashes = transactions.map { $0.txHash }
            let unconfirmedTransactions = try TransactionEvent.unconfirmedEvents(for: txHashes, database: persistance.connection())
            
            for unconfirmedTransaction in unconfirmedTransactions {
                guard let transaction = transactions.first(where: { $0.txHash == unconfirmedTransaction.txHash }) else { continue }
                try transaction.updateBlockHeight(database: persistance.connection())
            }
        } catch {
            print("⚠️ `\(#function)`:", error)
        }
        
        // add unknown transactions, fail on first error
        do {
            for transaction in transactions {
                try transaction.insert(database: persistance.connection())
            }
        } catch {
            print("⚠️ `\(#function)`:", error)
        }
    }
    
    private func addInvoices(_ invoices: [Invoice]) {
        do {
            for invoice in invoices {
                let createInvoiceEvent = CreateInvoiceEvent(invoice: invoice)
                try createInvoiceEvent.insert(database: persistance.connection())
                
                if invoice.settled {
                    let paymentEvent = LightningPaymentEvent(invoice: invoice)
                    try paymentEvent.insert(database: persistance.connection())
                }
            }
        } catch {
            print("⚠️ `\(#function)`:", error)
        }
    }
    
    private func addPayments(_ payments: [Payment]) {
        do {
            for payment in payments {
                let paymentEvent = LightningPaymentEvent(payment: payment, memo: nil)
                try paymentEvent.insert(database: persistance.connection())
            }
        } catch {
            print("⚠️ `\(#function)`:", error)
        }
    }
}
