//
//  Lightning
//
//  Created by Otto Suess on 18.09.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import BTCUtil
import Foundation
import SwiftLnd

public final class HistoryService {
    private let api: LightningApiProtocol
    private let channelService: ChannelService

    public var events = [HistoryEventType]()
    public var userTransaction = [PlottableEvent]()
    
    init(api: LightningApiProtocol, channelService: ChannelService) {
        self.api = api
        self.channelService = channelService
        
        updateEvents()
    }
    
    private func updateEvents() {
        do {
            var dateProvidingEvents = [DateProvidingEvent]()
            let payments = try TransactionEvent.payments()
            let lightningPayments = try LightningPaymentEvent.events()
            
            dateProvidingEvents.append(contentsOf: payments)
            dateProvidingEvents.append(contentsOf: lightningPayments)
            dateProvidingEvents.append(contentsOf: try CreateInvoiceEvent.events())
            dateProvidingEvents.append(contentsOf: try FailedPaymentEvent.events())
            
            let dateEstimator = DateEstimator()
            let channelEvents = try ChannelEvent.events().map { (channelEvent: ChannelEvent) -> DateWrappedChannelEvent in
                dateEstimator.wrapChannelEvent(channelEvent)
            }
            
            dateProvidingEvents.append(contentsOf: channelEvents)
            
            events = dateProvidingEvents.map(HistoryEventType.create)
            userTransaction = payments as [PlottableEvent] + lightningPayments as [PlottableEvent]
        } catch {
            fatalError("DB Error: \(error)")
        }
    }
    
    public func update() {
        api.transactions { [addTransactions] in
            guard let transactions = $0.value else { return }
            addTransactions(transactions)
        }
        
        api.payments { [addPayments] in
            guard let payments = $0.value else { return }
            addPayments(payments)
        }
        
        api.invoices { [addInvoices] in
            guard let invoices = $0.value else { return }
            addInvoices(invoices)
        }
    }
    
    func addFailedPaymentEvent(paymentRequest: PaymentRequest, amount: Satoshi) {
        do {
            let failedEvent = FailedPaymentEvent(paymentRequest: paymentRequest, amount: amount)
            try failedEvent.insert()
            events.insert(.failedPaymentEvent(failedEvent), at: 0)
            sendChangeNotification()
        } catch {
            print(error)
        }
    }
    
    func addPaymentEvent(payment: Payment, memo: String?) {
        do {
            let paymentEvent = LightningPaymentEvent(payment: payment, memo: memo)
            try paymentEvent.insert()
            events.insert(.lightningPaymentEvent(paymentEvent), at: 0)
            sendChangeNotification()
        } catch {
            print(error)
        }
    }
    
    func addUnconfirmedTransaction(txId: String, amount: Satoshi, memo: String?, destinationAddress: BitcoinAddress) {
        do {
            let transactionEvent = TransactionEvent(txId: txId, amount: amount, memo: memo, destinationAddress: destinationAddress)
            try transactionEvent.insert()
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
        
    }
}

// MARK: - Persistance
extension HistoryService {
    func addTransactions(_ transactions: [OnChainConfirmedTransaction]) {
        let transactions = transactions.map { TransactionEvent(transaction: $0) }
        
        // update unconfirmed transaction block height
        do {
            let txHashes = transactions.map { $0.txHash }
            let unconfirmedTransactions = try TransactionEvent.unconfirmedEvents(for: txHashes)
            
            for unconfirmedTransaction in unconfirmedTransactions {
                guard let transaction = transactions.first(where: { $0.txHash == unconfirmedTransaction.txHash }) else { continue }
                try transaction.updateBlockHeight()
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
    
    func addInvoices(_ invoices: [Invoice]) {
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
    
    func addPayments(_ payments: [Payment]) {
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
