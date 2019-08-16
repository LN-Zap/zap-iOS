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

    init(invoiceListUpdater: InvoiceListUpdater, transactionListUpdater: TransactionListUpdater, paymentListUpdater: PaymentListUpdater, channelListUpdater: ChannelListUpdater) {
        super.init()

        combineLatest(
            invoiceListUpdater.items,
            transactionListUpdater.items,
            paymentListUpdater.items,
            channelListUpdater.all,
            channelListUpdater.closed)
            .observeNext { [weak self] in
                let (invoiceChangeset, transactionChangeset, paymentChangeset, channels, closedChannels) = $0
                let dateEstimator = DateEstimator(transactions: transactionChangeset.collection)

                let newInvoices = invoiceChangeset.collection
                    .map { (invoice: Invoice) -> DateProvidingEvent in
                        InvoiceEvent(invoice: invoice)
                    }

                let channelTxids = channels.collection.map { $0.channelPoint.fundingTxid }
                    + closedChannels.collection.map { $0.channelPoint.fundingTxid }
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
                let newOpenChannelEvents = channels.collection
                    .compactMap { (channel: Channel) -> DateProvidingEvent? in
                        guard let channel = channel as? OpenChannel else { return nil }
                        return ChannelEvent(channel: channel, dateEstimator: dateEstimator)
                    }
                let newOpenChannelEvents2 = closedChannels.collection
                    .compactMap { (channelCloseSummary: ChannelCloseSummary) -> DateProvidingEvent? in
                        ChannelEvent(opening: channelCloseSummary, dateEstimator: dateEstimator)
                    }
                let newCloseChannelEvents = closedChannels.collection
                    .compactMap { (channelCloseSummary: ChannelCloseSummary) -> DateProvidingEvent? in
                        ChannelEvent(closing: channelCloseSummary, dateEstimator: dateEstimator)
                    }

                var result = newInvoices + newTransactions + newPayments + newOpenChannelEvents + newOpenChannelEvents2 + newCloseChannelEvents
                result.sort(by: { $0.date < $1.date })

                self?.events.replace(with: result.map(HistoryEventType.create))
            }
            .dispose(in: reactive.bag)
    }
}
