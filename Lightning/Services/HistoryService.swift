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
        api.transactions {
            guard let transactions = $0.value else { return }
            DatabaseUpdater.addTransactions(transactions)
        }
        
        api.payments {
            guard let payments = $0.value else { return }
            DatabaseUpdater.addPayments(payments)
        }
        
        api.invoices {
            guard let invoices = $0.value else { return }
            DatabaseUpdater.addInvoices(invoices)
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
        DatabaseUpdater.addTransactions([transaction])
        let transactionEvent = TransactionEvent(transaction: transaction)
        events.insert(.transactionEvent(transactionEvent), at: 0)
        sendChangeNotification()
    }
    
    func addedInvoice(_ invoice: Invoice) {
        DatabaseUpdater.addInvoices([invoice])
        let invoiceEvent = CreateInvoiceEvent(invoice: invoice)
        events.insert(.createInvoiceEvent(invoiceEvent), at: 0)
        sendChangeNotification()
    }
    
    private func sendChangeNotification() {
        
    }
}
