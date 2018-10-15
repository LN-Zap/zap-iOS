//
//  Library
//
//  Created by Otto Suess on 22.09.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import BTCUtil
import Foundation
import Lightning

final class EventDetailViewController: ModalDetailViewController {
    let event: HistoryEventType
    let presentBlockExplorer: (String, BlockExplorer.CodeType) -> Void
    
    init(event: HistoryEventType, presentBlockExplorer: @escaping (String, BlockExplorer.CodeType) -> Void) {
        self.event = event
        self.presentBlockExplorer = presentBlockExplorer
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupEvent(event)
    }
    
    private func setupEvent(_ event: HistoryEventType) {
        switch event {
        case .transactionEvent(let event):
            addHeadline("scene.transaction_detail.title.transaction_detail".localized)
            addAmountLabel(title: "scene.transaction_detail.amount_label".localized, amount: event.amount)
            addAmountLabel(title: "scene.transaction_detail.fee_label".localized, amount: event.fee)
            addLabel(title: "scene.transaction_detail.memo_label".localized, content: event.memo)
            addDateLabel(title: "scene.transaction_detail.date_label".localized, date: event.date)
            addBlockExplorerButton(title: "scene.transaction_detail.transaction_id_label".localized, code: event.txHash, type: .transactionId)
            addBlockExplorerButton(title: "scene.transaction_detail.address_label".localized, code: event.destinationAddresses.first?.string, type: .address)
            
        case .channelEvent(let event):
            addHeadline("scene.transaction_detail.title.channel_event_detail".localized)
            addAmountLabel(title: "scene.transaction_detail.fee_label".localized, amount: event.channelEvent.fee)
            addDateLabel(title: "scene.transaction_detail.date_label".localized, date: event.date)
            addBlockExplorerButton(title: "scene.transaction_detail.transaction_id_label".localized, code: event.channelEvent.txHash, type: .transactionId)

        case .createInvoiceEvent(let event):
            addHeadline("scene.transaction_detail.title.lightning_invoice".localized)
            addAmountLabel(title: "scene.transaction_detail.amount_label".localized, amount: event.amount)
            addLabel(title: "scene.transaction_detail.memo_label".localized, content: event.memo)
            addDateLabel(title: "scene.transaction_detail.date_label".localized, date: event.date)
            addDateLabel(title: "scene.transaction_detail.expiry_label".localized, date: event.expiry)
            
        case .failedPaymentEvent(let event):
            addHeadline("scene.transaction_detail.title.failed_payment".localized)
            addAmountLabel(title: "scene.transaction_detail.amount_label".localized, amount: event.amount)
            addLabel(title: "scene.transaction_detail.memo_label".localized, content: event.memo)
            addDateLabel(title: "scene.transaction_detail.date_label".localized, date: event.date)
            
        case .lightningPaymentEvent(let event):
            addHeadline("scene.transaction_detail.title.payment_detail".localized)
            addLabel(title: "scene.transaction_detail.memo_label".localized, content: event.memo)
            addAmountLabel(title: "scene.transaction_detail.amount_label".localized, amount: event.amount)
            addAmountLabel(title: "scene.transaction_detail.fee_label".localized, amount: event.fee)
            addDateLabel(title: "scene.transaction_detail.date_label".localized, date: event.date)
        }
    }
    
    private func addLabel(title: String, element: StackViewElement) {
        contentStackView.addArrangedElement(.horizontalStackView(compressionResistant: .first, content: [
            .label(text: title, style: Style.Label.headline),
            element
        ]))
    }
    
    private func addLabel(title: String, content: String?) {
        guard let content = content else { return }
        addLabel(title: title, element: .label(text: content, style: Style.Label.body))
    }
    
    private func addAmountLabel(title: String, amount: Satoshi?) {
        guard let amount = amount else { return }
        addLabel(title: title, element: .amountLabel(amount: amount, style: Style.Label.body))
    }
    
    private func addDateLabel(title: String, date: Date) {
        let dateString = DateFormatter.localizedString(from: date, dateStyle: .medium, timeStyle: .medium)
        addLabel(title: title, content: dateString)
    }
    
    private func addBlockExplorerButton(title: String, code: String?, type: BlockExplorer.CodeType) {
        guard let code = code else { return }
        addLabel(title: title, element: .button(title: code, style: Style.Button.custom(), completion: { [weak self] _ in
            self?.dismiss(animated: true, completion: {
                self?.presentBlockExplorer(code, type)
            })
        }))
    }
}
