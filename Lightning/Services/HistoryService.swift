//
//  Lightning
//
//  Created by Otto Suess on 18.09.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import BTCUtil
import Foundation
import SwiftLnd

public enum HistoryEventType: Equatable {
    case transactionEvent(TransactionEvent)
    case channelEvent(DateWrappedChannelEvent)
    case createInvoiceEvent(CreateInvoiceEvent)
    case failedPaymentEvent(FailedPaymentEvent)
    case lightningPaymentEvent(LightningPaymentEvent)
    
    fileprivate static func create(event: DateProvidingEvent) -> HistoryEventType {
        if let channelEvent = event as? DateWrappedChannelEvent {
            return HistoryEventType.channelEvent(channelEvent)
        } else if let transactionEvent = event as? TransactionEvent {
            return HistoryEventType.transactionEvent(transactionEvent)
        } else if let createInvoiceEvent = event as? CreateInvoiceEvent {
            return HistoryEventType.createInvoiceEvent(createInvoiceEvent)
        } else if let failedPaymentEvent = event as? FailedPaymentEvent {
            return HistoryEventType.failedPaymentEvent(failedPaymentEvent)
        } else if let lightningPaymentEvent = event as? LightningPaymentEvent {
            return HistoryEventType.lightningPaymentEvent(lightningPaymentEvent)
        } else {
            fatalError("missing cell implementation")
        }
    }
    
    public var date: Date {
        switch self {
        case .transactionEvent(let event):
            return event.date
        case .channelEvent(let event):
            return event.date
        case .createInvoiceEvent(let event):
            return event.date
        case .failedPaymentEvent(let event):
            return event.date
        case .lightningPaymentEvent(let event):
            return event.date
        }
    }
}

public final class HistoryService {
    private let api: LightningApiProtocol
    private let channelService: ChannelService

    public var events = [HistoryEventType]()
    
    init(api: LightningApiProtocol, channelService: ChannelService) {
        self.api = api
        self.channelService = channelService
        
        updateEvents()
    }
    
    private func updateEvents() {
        do {
            var dateProvidingEvents = [DateProvidingEvent]()
            
            dateProvidingEvents.append(contentsOf: try TransactionEvent.payments())
            dateProvidingEvents.append(contentsOf: try CreateInvoiceEvent.events())
            dateProvidingEvents.append(contentsOf: try FailedPaymentEvent.events())
            dateProvidingEvents.append(contentsOf: try LightningPaymentEvent.events())
            
            let dateEstimator = DateEstimator()
            let channelEvents = try ChannelEvent.events().map { (channelEvent: ChannelEvent) -> DateWrappedChannelEvent in
                dateEstimator.wrapChannelEvent(channelEvent)
            }
            
            dateProvidingEvents.append(contentsOf: channelEvents)
            
            events = dateProvidingEvents.map(HistoryEventType.create)
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
