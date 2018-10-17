//
//  Library
//
//  Created by Otto Suess on 17.10.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation
import Lightning
import SwiftBTC

protocol EventDetailViewModelDelegate: class {
    func openBlockExplorer(code: String, type: BlockExplorer.CodeType)
}

final class EventDetailViewModel {
    private let event: HistoryEventType
    
    init(event: HistoryEventType) {
        self.event = event
    }
    
    func detailConfiguration(delegate: EventDetailViewModelDelegate) -> [StackViewElement] {
        var result = [StackViewElement]()
        
        switch event {
        case .transactionEvent(let event):
            result.append(contentsOf: headline("scene.transaction_detail.title.transaction_detail".localized))
            result.append(contentsOf: amountLabel(title: "scene.transaction_detail.amount_label".localized, amount: event.amount))
            result.append(contentsOf: amountLabel(title: "scene.transaction_detail.fee_label".localized, amount: event.fee, skipZero: true))
            result.append(contentsOf: label(title: "scene.transaction_detail.memo_label".localized, content: event.memo))
            result.append(contentsOf: dateLabel(title: "scene.transaction_detail.date_label".localized, date: event.date))
            result.append(contentsOf: blockExplorerButton(title: "scene.transaction_detail.transaction_id_label".localized, code: event.txHash, type: .transactionId, delegate: delegate))
            result.append(contentsOf: blockExplorerButton(title: "scene.transaction_detail.address_label".localized, code: event.destinationAddresses.first?.string, type: .address, delegate: delegate))
            
        case .channelEvent(let event):
            result.append(contentsOf: headline("scene.transaction_detail.title.channel_event_detail".localized))
            result.append(contentsOf: amountLabel(title: "scene.transaction_detail.fee_label".localized, amount: event.channelEvent.fee, skipZero: true))
            result.append(contentsOf: dateLabel(title: "scene.transaction_detail.date_label".localized, date: event.date))
            result.append(contentsOf: blockExplorerButton(title: "scene.transaction_detail.transaction_id_label".localized, code: event.channelEvent.txHash, type: .transactionId, delegate: delegate))
            
        case .createInvoiceEvent(let event):
            result.append(contentsOf: headline("scene.transaction_detail.title.lightning_invoice".localized))
            result.append(contentsOf: amountLabel(title: "scene.transaction_detail.amount_label".localized, amount: event.amount))
            result.append(contentsOf: label(title: "scene.transaction_detail.memo_label".localized, content: event.memo))
            result.append(contentsOf: dateLabel(title: "scene.transaction_detail.date_label".localized, date: event.date))
            result.append(contentsOf: dateLabel(title: "scene.transaction_detail.expiry_label".localized, date: event.expiry))
            
        case .failedPaymentEvent(let event):
            result.append(contentsOf: headline("scene.transaction_detail.title.failed_payment".localized))
            result.append(contentsOf: amountLabel(title: "scene.transaction_detail.amount_label".localized, amount: event.amount))
            result.append(contentsOf: label(title: "scene.transaction_detail.memo_label".localized, content: event.memo))
            result.append(contentsOf: dateLabel(title: "scene.transaction_detail.date_label".localized, date: event.date))
            
        case .lightningPaymentEvent(let event):
            result.append(contentsOf: headline("scene.transaction_detail.title.payment_detail".localized))
            result.append(contentsOf: label(title: "scene.transaction_detail.memo_label".localized, content: event.memo))
            result.append(contentsOf: amountLabel(title: "scene.transaction_detail.amount_label".localized, amount: event.amount))
            result.append(contentsOf: amountLabel(title: "scene.transaction_detail.fee_label".localized, amount: event.fee))
            result.append(contentsOf: dateLabel(title: "scene.transaction_detail.date_label".localized, date: event.date))
        }
        
        return result
    }
    
    func headline(_ headline: String) -> [StackViewElement] {
        return [
            .label(text: headline, style: Style.Label.headline.with({ $0.textAlignment = .center })),
            .separator
        ]
    }
    
    private func label(title: String, element: StackViewElement) -> [StackViewElement] {
        return [
            .horizontalStackView(compressionResistant: .first, content: [
                .label(text: title, style: Style.Label.headline),
                element
            ])
        ]
    }
    
    private func label(title: String, content: String?) -> [StackViewElement] {
        guard let content = content else { return [] }
        return label(title: title, element: .label(text: content, style: Style.Label.body))
    }
    
    private func amountLabel(title: String, amount: Satoshi?, skipZero: Bool = false) -> [StackViewElement] {
        guard
            let amount = amount,
            !skipZero || amount != 0
            else { return [] }
        return label(title: title, element: .amountLabel(amount: amount, style: Style.Label.body))
    }
    
    private func dateLabel(title: String, date: Date) -> [StackViewElement] {
        let dateString = DateFormatter.localizedString(from: date, dateStyle: .medium, timeStyle: .medium)
        return label(title: title, content: dateString)
    }
    
    private func blockExplorerButton(title: String, code: String?, type: BlockExplorer.CodeType, delegate: EventDetailViewModelDelegate?) -> [StackViewElement] {
        guard let code = code else { return [] }
        return label(title: title, element: .button(title: code, style: Style.Button.custom(), completion: { _ in
            delegate?.openBlockExplorer(code: code, type: type)
        }))
    }
}
