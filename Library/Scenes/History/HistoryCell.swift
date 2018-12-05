//
//  Zap
//
//  Created by Otto Suess on 21.01.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import Lightning
import SwiftBTC
import UIKit

protocol HistoryCellDelegate: class {
    func resendFailedPayment(_ failedPaymentEvent: FailedPaymentEvent)
}
    
final class HistoryCell: BondTableViewCell {
    enum NotificationType {
        case error
        case new
        
        var style: (UIColor, String) {
            switch self {
            case .error:
                return (UIColor.Zap.superRed, L10n.Scene.History.Cell.Label.error)
            case .new:
                return (UIColor.Zap.purple, L10n.Scene.History.Cell.Label.new)
            }
        }
    }
    
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var stackView: UIStackView!
    @IBOutlet private weak var notificationLabel: PaddingLabel!
    @IBOutlet private var notificationTopConstraint: NSLayoutConstraint!
    
    private weak var delegate: HistoryCellDelegate?
    private var containerBackgroundColor = UIColor.Zap.seaBlue
    
    func addNotificationLabel(type: NotificationType) {
        let (color, text) = type.style
        notificationLabel.backgroundColor = color
        notificationLabel.text = text

        setNotificationLabelHidden(false)
    }
    
    func setNotificationLabelHidden(_ hidden: Bool) {
        notificationTopConstraint.isActive = !hidden
        notificationLabel.isHidden = hidden
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        containerBackgroundColor = UIColor.Zap.seaBlue
        stackView.clear()
        setNotificationLabelHidden(true)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setNotificationLabelHidden(true)

        containerView.backgroundColor = UIColor.Zap.seaBlue
        containerView.layer.cornerRadius = Appearance.Constants.modalCornerRadius
        
        Style.Label.footnote.apply(to: notificationLabel)
        notificationLabel.textColor = UIColor.Zap.white
        notificationLabel.edgeInsets = UIEdgeInsets(top: 0, left: 7, bottom: 0, right: 7)
        notificationLabel.layer.cornerRadius = 7
        notificationLabel.layer.masksToBounds = true
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        setSelectedOrHighlighted(highlighted, animated: animated)
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        setSelectedOrHighlighted(selected, animated: animated)
    }
    
    func setSelectedOrHighlighted(_ selectedOrHighlighted: Bool, animated: Bool) {
        let action = { [weak self] in
            if selectedOrHighlighted {
                self?.containerView.backgroundColor = UIColor.Zap.gray
            } else {
                self?.containerView.backgroundColor = self?.containerBackgroundColor
            }
        }
        
        if animated {
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: action, completion: nil)
        } else {
            action()
        }
    }
    
    private func amountLabel(_ amount: Satoshi?, completed: Bool = true) -> UILabel {
        let amountLabel = PaddingLabel(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        Style.Label.body.apply(to: amountLabel)

        if let amount = amount {
            amount
                .bind(to: amountLabel.reactive.text, currency: Settings.shared.primaryCurrency)
                .dispose(in: onReuseBag)

            if !completed {
                amountLabel.textColor = UIColor.Zap.gray
            } else if amount > 0 {
                amountLabel.backgroundColor = UIColor.Zap.superGreen.withAlphaComponent(0.1)
                amountLabel.textColor = UIColor.Zap.superGreen
                amountLabel.layer.cornerRadius = 4
                amountLabel.layer.masksToBounds = true
                amountLabel.edgeInsets = UIEdgeInsets(top: 2, left: 6, bottom: 2, right: 6)
            }
        } else {
            amountLabel.text = nil
        }
        return amountLabel
    }
    
    func setTransactionEvent(_ transactionEvent: TransactionEvent) {
        let title = transactionEvent.amount < 0 ? L10n.Scene.History.Cell.transactionSent : L10n.Scene.History.Cell.transactionReceived
        setTitle(title, date: transactionEvent.date)

        let description = transactionEvent.memo ?? transactionEvent.destinationAddresses.first?.string ?? L10n.Transaction.noDestinationAddress
        
        if transactionEvent.type == .unknown {
            containerBackgroundColor = UIColor.Zap.invisibleGray
        }
        
        stackView.addArrangedElement(.horizontalStackView(compressionResistant: .last, content: [
            .label(text: description, style: Style.Label.body),
            .customView(amountLabel(transactionEvent.amount))
        ]))
    }
    
    func setChannelEvent(_ wrapped: DateWrappedChannelEvent) {
        let title: String
        switch wrapped.channelEvent.type {
        case .open:
            title = L10n.Scene.History.Cell.channelOpened
        case .cooperativeClose, .unknown:
            title = L10n.Scene.History.Cell.channelClosed
        case .localForceClose:
            title = L10n.Scene.History.Cell.forceCloseChannel
        case .remoteForceClose:
            title = L10n.Scene.History.Cell.remoteForceCloseChannel
        case .breachClose:
            title = L10n.Scene.History.Cell.breachCloseChannel
        case .fundingCanceled:
            title = L10n.Scene.History.Cell.closeChannelFundingCanceled
        case .abandoned:
            title = L10n.Scene.History.Cell.channelAbandoned
        }

        setTitle(title, date: wrapped.date)

        let amount: Satoshi?
        if let newAmount = wrapped.channelEvent.fee, newAmount > 0 {
            amount = -newAmount
        } else {
            amount = nil
        }
        
        stackView.addArrangedElement(.horizontalStackView(compressionResistant: .last, content: [
            .label(text: wrapped.channelEvent.node.alias ?? wrapped.channelEvent.node.pubKey, style: Style.Label.body),
            .customView(amountLabel(amount))
        ]))
    }
    
    private func setTitle(_ title: String, date: Date) {
        let timeFormatter = DateFormatter()
        timeFormatter.dateStyle = .none
        timeFormatter.timeStyle = .short
        timeFormatter.doesRelativeDateFormatting = true
        let dateString = timeFormatter.string(from: date)
        
        stackView.addArrangedElement(.horizontalStackView(compressionResistant: .last, content: [
            .label(text: title, style: Style.Label.headline),
            .label(text: dateString, style: Style.Label.footnote)
        ]))
    }
    
    func setCreateInvoiceEvent(_ createInvoiceEvent: CreateInvoiceEvent) {
        setTitle(L10n.Scene.History.Cell.invoiceCreated, date: createInvoiceEvent.date)
        
        stackView.addArrangedElement(.horizontalStackView(compressionResistant: .last, content: [
            .label(text: createInvoiceEvent.memo ?? createInvoiceEvent.paymentRequest, style: Style.Label.body),
            .customView(amountLabel(createInvoiceEvent.amount, completed: false))
        ]))
    }
    
    func setFailedPaymentEvent(_ failedPaymentEvent: FailedPaymentEvent, delegate: HistoryCellDelegate) {
        self.delegate = delegate
        
        let title = L10n.Scene.History.Cell.paymentFailed(failedPaymentEvent.node.alias ?? failedPaymentEvent.node.pubKey)
        setTitle(title, date: failedPaymentEvent.date)
        
        let description = failedPaymentEvent.memo ?? failedPaymentEvent.paymentRequest
        
        stackView.addArrangedElement(.horizontalStackView(compressionResistant: .last, content: [
            .label(text: description, style: Style.Label.body),
            .customView(amountLabel(-failedPaymentEvent.amount))
        ]))
        
        addNotificationLabel(type: .error)

        if !failedPaymentEvent.isExpired {
            stackView.addArrangedElement(.button(title: L10n.Scene.History.Cell.Action.tryAgain, style: Style.Button.custom(), completion: { [weak self] _ in
                self?.delegate?.resendFailedPayment(failedPaymentEvent)
            }))
        }
    }
    
    func setLightningPaymentEvent(_ lightningPaymentEvent: LightningPaymentEvent) {
        let title: String
        if lightningPaymentEvent.amount <= 0 {
            title = L10n.Scene.History.Cell.paymentSent
        } else {
            title = L10n.Scene.History.Cell.paymentReceived
        }

        setTitle(title, date: lightningPaymentEvent.date)

        let detailLabel = lightningPaymentEvent.node?.alias ?? lightningPaymentEvent.node?.pubKey ?? L10n.Scene.TransactionDetail.amountLabel
        stackView.addArrangedElement(.horizontalStackView(compressionResistant: .last, content: [
            .label(text: detailLabel, style: Style.Label.body),
            .customView(amountLabel(lightningPaymentEvent.amount))
        ]))

        if let memo = lightningPaymentEvent.memo, !memo.isEmpty {
            stackView.addArrangedElement(.horizontalStackView(compressionResistant: .first, content: [
                .label(text: "memo:", style: Style.Label.body),
                .label(text: memo, style: Style.Label.body.with({
                    $0.lineBreakMode = .byTruncatingTail
                    $0.textColor = UIColor.Zap.gray
                }))
            ]))
        }
    }
}
