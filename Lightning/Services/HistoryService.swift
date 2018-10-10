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
    private let persistence: Persistence
    
    public var events = [HistoryEventType]()
    public var userTransaction = [PlottableEvent]()
    
    init(api: LightningApiProtocol, channelService: ChannelService, persistence: Persistence) {
        self.api = api
        self.channelService = channelService
        self.persistence = persistence
    }
    
    /// Load all transactions from db
    private func updateEvents() {
        do {
            let database = try persistence.connection()
            
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
            let connection = try persistence.connection()
            guard try !LightningPaymentEvent.contains(database: connection, paymentHash: paymentRequest.paymentHash) else { return }
            let failedEvent = FailedPaymentEvent(paymentRequest: paymentRequest, amount: amount)
            try failedEvent.insert(database: connection)
            events.insert(.failedPaymentEvent(failedEvent), at: 0)
            sendChangeNotification()
        } catch {
            print(error)
        }
    }
    
    func addPaymentEvent(payment: Payment, memo: String?) {
        channelService.node(for: payment.destination) { [weak self] node in
            do {
                guard let self = self else { return }
                let paymentEvent = LightningPaymentEvent(payment: payment, memo: memo, node: node)
                try paymentEvent.insert(database: self.persistence.connection())
                self.events.insert(.lightningPaymentEvent(paymentEvent), at: 0)
                self.sendChangeNotification()
            } catch {
                print(error)
            }
        }
    }
    
    func addedTransaction(_ transaction: Transaction) {
        addTransactions([transaction])
        
//        guard let transactionEvent = TransactionEvent(transaction: transaction) else { return }
//        events.insert(.transactionEvent(transactionEvent), at: 0)
        sendChangeNotification()
    }
    
    func addedInvoice(_ invoice: Invoice) {
        addInvoices([invoice])
        
//        let invoiceEvent = CreateInvoiceEvent(invoice: invoice)
//        events.insert(.createInvoiceEvent(invoiceEvent), at: 0)
        sendChangeNotification()
    }
    
    private func sendChangeNotification() {
        NotificationCenter.default.post(name: .historyDidChange, object: nil)
    }
}

// MARK: - Persistence
extension HistoryService {
    private func addTransactions(_ transactions: [Transaction]) {
        let receiveAddresses = (try? ReceivingAddress.all(database: persistence.connection())) ?? Set()
        
        let transactions = transactions.compactMap { transaction -> TransactionEvent? in
            for destination in transaction.destinationAddresses where receiveAddresses.contains(destination) {
                return TransactionEvent(transaction: transaction, type: .userInitiated)
            }
            return TransactionEvent(transaction: transaction, type: .unknown)
        }
        
        // update unconfirmed transaction block height
        do {
            let txHashes = transactions.map { $0.txHash }
            let unconfirmedTransactions = try TransactionEvent.unconfirmedEvents(for: txHashes, database: persistence.connection())
            
            for unconfirmedTransaction in unconfirmedTransactions {
                guard let transaction = transactions.first(where: { $0.txHash == unconfirmedTransaction.txHash }) else { continue }
                try transaction.updateBlockHeight(database: persistence.connection())
            }
        } catch {
            print("⚠️ `\(#function)` (update unconfirmed):", error)
        }
        
        // add unknown transactions, fail on first error
        for transaction in transactions {
            do {
                try transaction.insert(database: persistence.connection())
            } catch {
                print("⚠️ `\(#function)` (add unknown):", error)
            }
        }
    }
    
    private func addInvoices(_ invoices: [Invoice]) {
        do {
            for invoice in invoices {
                let createInvoiceEvent = CreateInvoiceEvent(invoice: invoice)
                try createInvoiceEvent.insert(database: persistence.connection())
                
                if invoice.settled {
                    let paymentEvent = LightningPaymentEvent(invoice: invoice)
                    try paymentEvent.insert(database: persistence.connection())
                }
            }
        } catch {
            print("⚠️ `\(#function)`:", error)
        }
    }
    
    private func addPayments(_ payments: [Payment]) {
        do {
            for payment in payments {
                let paymentEvent = LightningPaymentEvent(payment: payment, memo: nil, node: nil)
                try paymentEvent.insert(database: persistence.connection())
            }
        } catch {
            print("⚠️ `\(#function)`:", error)
        }
    }
}
