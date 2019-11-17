//
//  Library
//
//  Created by Otto Suess on 17.10.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation
import Lightning
import ReactiveKit
import SwiftBTC

struct BlockExplorerItem {
    let code: String
    let type: BlockExplorer.CodeType
}

final class EventDetailViewModel {
    private let event: HistoryEventType
    
    let blockExplorerButtonTapped = Subject<BlockExplorerItem, NoError>()

    init(event: HistoryEventType) {
        self.event = event
    }

    func detailConfiguration() -> [StackViewElement] {
        var result = [StackViewElement]()

        switch event {
        case .transactionEvent(let event):
            result.append(contentsOf: headline(L10n.Scene.TransactionDetail.Title.transactionDetail))
            result.append(contentsOf: amountLabel(title: L10n.Scene.TransactionDetail.amountLabel, amount: event.amount))
            result.append(contentsOf: amountLabel(title: L10n.Scene.TransactionDetail.feeLabel, amount: event.fee, skipZero: true))
            result.append(contentsOf: dateLabel(title: L10n.Scene.TransactionDetail.dateLabel, date: event.date))
            result.append(contentsOf: blockExplorerButton(title: L10n.Scene.TransactionDetail.transactionIdLabel, code: event.txHash, type: .transactionId))
            result.append(contentsOf: blockExplorerButton(title: L10n.Scene.TransactionDetail.addressLabel, code: event.destinationAddresses.first?.string, type: .address))
        case .channelEvent(let event):
            result.append(contentsOf: headline(L10n.Scene.TransactionDetail.Title.channelEventDetail))
            result.append(contentsOf: amountLabel(title: L10n.Scene.TransactionDetail.feeLabel, amount: event.fee, skipZero: true))
            result.append(contentsOf: dateLabel(title: L10n.Scene.TransactionDetail.dateLabel, date: event.date))
            result.append(contentsOf: blockExplorerButton(title: L10n.Scene.TransactionDetail.transactionIdLabel, code: event.txHash, type: .transactionId))
        case .createInvoiceEvent(let event):
            return createInvoiceEvent(event: event)
        case .lightningPaymentEvent(let event):
            return lightningPaymentEvent(event: event)
        }

        return result
    }

    private func createInvoiceEvent(event: InvoiceEvent) -> [StackViewElement] {
        var result = [StackViewElement]()

        result.append(contentsOf: headline(L10n.Scene.TransactionDetail.Title.lightningInvoice))

        if !event.isExpired && event.state != .settled && event.state != .canceled,
            let qrCodeImage = UIImage.qrCode(from: event.paymentRequest) {
            let imageContainerView = UIView()
            let callbackButton = CallbackButton(title: nil, type: .custom) { _ in
                Toast.presentSuccess(L10n.Scene.TransactionDetail.invoiceCopyMessage)
                UIPasteboard.general.string = event.paymentRequest
            }
            callbackButton.button.setImage(qrCodeImage, for: .normal)

            imageContainerView.addAutolayoutSubview(callbackButton)

            NSLayoutConstraint.activate([
                imageContainerView.heightAnchor.constraint(equalToConstant: 230),
                callbackButton.topAnchor.constraint(equalTo: imageContainerView.topAnchor),
                callbackButton.bottomAnchor.constraint(equalTo: imageContainerView.bottomAnchor),
                callbackButton.widthAnchor.constraint(equalTo: imageContainerView.heightAnchor),
                callbackButton.centerXAnchor.constraint(equalTo: imageContainerView.centerXAnchor)
            ])

            result.append(.customView(imageContainerView))
        }

        result.append(contentsOf: amountLabel(title: L10n.Scene.TransactionDetail.amountLabel, amount: event.amount))
        result.append(contentsOf: label(title: L10n.Scene.TransactionDetail.memoLabel, content: event.memo))
        result.append(contentsOf: dateLabel(title: L10n.Scene.TransactionDetail.dateLabel, date: event.date))

        if event.state != .settled {
            let expiryLabel = UILabel()
            Style.Label.body.apply(to: expiryLabel)
            expiryLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 17, weight: .light)
            updateExpiryLabel(expiryLabel, expiry: event.expiry)
            result.append(contentsOf: label(title: L10n.Scene.TransactionDetail.expiryLabel, element: .customView(expiryLabel)))
        } else {
            result.append(contentsOf: label(title: L10n.Scene.TransactionDetail.invoiceStateLabel, content: L10n.Scene.TransactionDetail.InvoiceStateLabel.settled))
        }

        return result
    }

    private func updateExpiryLabel(_ label: UILabel, expiry: Date) {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .short
        formatter.includesTimeRemainingPhrase = true
        formatter.zeroFormattingBehavior = .dropLeading
        formatter.maximumUnitCount = 2

        let timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) {
            let timeRemaining = expiry.timeIntervalSinceNow
            if timeRemaining < 0 {
                $0.invalidate()
                label.text = L10n.Scene.TransactionDetail.ExpiryLabel.expired
            } else {
                label.text = formatter.string(from: timeRemaining)
            }
        }
        timer.fire()
    }

    private func lightningPaymentEvent(event: LightningPaymentEvent) -> [StackViewElement] {
        var result = [StackViewElement]()

        result.append(contentsOf: headline(L10n.Scene.TransactionDetail.Title.paymentDetail))
        result.append(contentsOf: amountLabel(title: L10n.Scene.TransactionDetail.amountLabel, amount: event.amount))
        result.append(contentsOf: label(title: L10n.Scene.TransactionDetail.memoLabel, content: event.memo))
        result.append(contentsOf: amountLabel(title: L10n.Scene.TransactionDetail.feeLabel, amount: event.fee))
        result.append(contentsOf: copyButton(title: L10n.Scene.TransactionDetail.preimageLabel, content: event.preimage))
        result.append(contentsOf: dateLabel(title: L10n.Scene.TransactionDetail.dateLabel, date: event.date))

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
                .label(text: "\(title):", style: Style.Label.headline.with { $0.textColor = UIColor.Zap.gray }),
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

    private func blockExplorerButton(title: String, code: String?, type: BlockExplorer.CodeType) -> [StackViewElement] {
        guard let code = code else { return [] }
        return label(title: title, element: .button(title: code, style: Style.Button.custom(), completion: { [weak self] _ in
            guard let self = self else { return }
            self.blockExplorerButtonTapped.send(BlockExplorerItem(code: code, type: type))
        }))
    }

    private func copyButton(title: String, content: String) -> [StackViewElement] {
        return label(title: title, element: .button(title: content, style: Style.Button.custom(), completion: { _ in
            Toast.presentSuccess(L10n.Scene.TransactionDetail.preimageCopyMessage)
            UIPasteboard.general.string = content
        }))
    }
}
