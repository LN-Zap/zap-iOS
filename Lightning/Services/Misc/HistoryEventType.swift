//
//  Lightning
//
//  Created by Otto Suess on 19.09.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation

public enum HistoryEventType: Equatable {
    case transactionEvent(TransactionEvent)
    case channelEvent(ChannelEvent)
    case createInvoiceEvent(InvoiceEvent)
    case lightningPaymentEvent(LightningPaymentEvent)

    static func create(event: DateProvidingEvent) -> HistoryEventType {
        if let channelEvent = event as? ChannelEvent {
            return HistoryEventType.channelEvent(channelEvent)
        } else if let transactionEvent = event as? TransactionEvent {
            return HistoryEventType.transactionEvent(transactionEvent)
        } else if let createInvoiceEvent = event as? InvoiceEvent {
            return HistoryEventType.createInvoiceEvent(createInvoiceEvent)
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
        case .lightningPaymentEvent(let event):
            return event.date
        }
    }
}
