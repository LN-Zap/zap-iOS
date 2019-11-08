//
//  Lightning
//
//  Created by Otto Suess on 18.09.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Bond
import Foundation
import Logger
import ReactiveKit
import SwiftBTC
import SwiftLnd

public final class HistoryService: NSObject {
    public var events = MutableObservableArray<HistoryEventType>()

    private let invoiceListUpdater: InvoiceListUpdater
    private let transactionListUpdater: TransactionListUpdater
    private let paymentListUpdater: PaymentListUpdater
    private let channelListUpdater: ChannelListUpdater
    
    init(invoiceListUpdater: InvoiceListUpdater, transactionListUpdater: TransactionListUpdater, paymentListUpdater: PaymentListUpdater, channelListUpdater: ChannelListUpdater) { // swiftlint:disable:this function_body_length
        self.invoiceListUpdater = invoiceListUpdater
        self.transactionListUpdater = transactionListUpdater
        self.paymentListUpdater = paymentListUpdater
        self.channelListUpdater = channelListUpdater
        
        super.init()

        combineLatest(
            invoiceListUpdater.items,
            transactionListUpdater.items,
            paymentListUpdater.items,
            channelListUpdater.open,
            channelListUpdater.pending,
            channelListUpdater.closed)
            .observeNext { [weak self] in
                let (invoiceChangeset, transactionChangeset, paymentChangeset, openChannels, pendingChannels, closedChannels) = $0
                let dateEstimator = DateEstimator(transactions: transactionChangeset.collection)

                let newInvoices = invoiceChangeset.collection
                    .map { (invoice: Invoice) -> DateProvidingEvent in
                        InvoiceEvent(invoice: invoice)
                    }

                let channelTxids = openChannels.collection.map { $0.channelPoint.fundingTxid }
                    + closedChannels.collection.map { $0.channelPoint.fundingTxid }
                    + pendingChannels.collection.map { $0.channelPoint.fundingTxid }
                    + closedChannels.collection.map { $0.closingTxHash }
                let newTransactions = transactionChangeset.collection
                    .filter { !channelTxids.contains($0.id) }
                    .compactMap { (transaction: Transaction) -> DateProvidingEvent? in
                        TransactionEvent(transaction: transaction)
                    }
                let newPayments = paymentChangeset.collection
                    .map { (payment: Payment) -> DateProvidingEvent in
                        LightningPaymentEvent(payment: payment)
                    }
                let newOpenChannelEvents = openChannels.collection
                    .compactMap { (channel: OpenChannel) -> DateProvidingEvent? in
                        ChannelEvent(channel: channel, dateEstimator: dateEstimator)
                    }
                let newPendingOpenChannelEvents = pendingChannels.collection
                    .compactMap { (channel: PendingChannel) -> DateProvidingEvent? in
                        guard let fundingTx = transactionChangeset.collection.first(where: { $0.id == channel.channelPoint.fundingTxid }) else { return nil }
                        return ChannelEvent(pendingChannel: channel, transaction: fundingTx)
                    }
                let newOpenChannelEvents2 = closedChannels.collection
                    .compactMap { (channelCloseSummary: ChannelCloseSummary) -> DateProvidingEvent? in
                        ChannelEvent(opening: channelCloseSummary, dateEstimator: dateEstimator)
                    }
                let newCloseChannelEvents = closedChannels.collection
                    .compactMap { (channelCloseSummary: ChannelCloseSummary) -> DateProvidingEvent? in
                        ChannelEvent(closing: channelCloseSummary, dateEstimator: dateEstimator)
                    }

                var result = newInvoices + newTransactions + newPayments + newOpenChannelEvents + newPendingOpenChannelEvents + newOpenChannelEvents2 + newCloseChannelEvents
                result.sort(by: { $0.date < $1.date })

                self?.events.replace(with: result.map(HistoryEventType.create))
            }
            .dispose(in: reactive.bag)
    }
    
    public func refresh() {
        invoiceListUpdater.update()
        transactionListUpdater.update()
        paymentListUpdater.update()
        channelListUpdater.update()
    }
}
