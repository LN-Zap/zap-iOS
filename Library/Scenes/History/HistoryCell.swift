//
//  Zap
//
//  Created by Otto Suess on 21.01.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import BTCUtil
import Lightning
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
                return (UIColor.Zap.superRed, "scene.history.cell.label.error".localized)
            case .new:
                return (UIColor.Zap.purple, "scene.history.cell.label.new".localized)
            }
        }
    }
    
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var amountLabel: PaddingLabel!
    @IBOutlet private weak var buttonContainer: UIView!
    @IBOutlet private weak var actionButton: UIButton!
    @IBOutlet private weak var notificationLabel: PaddingLabel!
    @IBOutlet private var notificationTopConstraint: NSLayoutConstraint!
    
    private weak var delegate: HistoryCellDelegate?
    private var failedPaymentEvent: FailedPaymentEvent?
    
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
        
        amountLabel.backgroundColor = .clear
        amountLabel.textColor = UIColor.Zap.white
        amountLabel.edgeInsets = .zero
        
        buttonContainer.isHidden = true
        
        setNotificationLabelHidden(true)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setNotificationLabelHidden(true)

        containerView.backgroundColor = UIColor.Zap.seaBlue
        containerView.layer.cornerRadius = Appearance.Constants.modalCornerRadius
        
        Style.Label.headline.apply(to: titleLabel)
        Style.Label.body.apply(to: descriptionLabel, amountLabel)
        Style.Label.footnote.apply(to: dateLabel)
        buttonContainer.isHidden = true
        
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
                self?.containerView.backgroundColor = UIColor.Zap.seaBlue
            }
        }
        
        if animated {
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: action, completion: nil)
        } else {
            action()
        }
    }
    
    private func setDate(_ date: Date) {
        let timeFormatter = DateFormatter()
        timeFormatter.dateStyle = .none
        timeFormatter.timeStyle = .short
        timeFormatter.doesRelativeDateFormatting = true
        dateLabel.text = timeFormatter.string(from: date)
    }
    
    private func setAmount(_ amount: Satoshi?, completed: Bool = true) {
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
    }
    
    func setTransactionEvent(_ transactionEvent: TransactionEvent) {
        if transactionEvent.amount < 0 {
            titleLabel.text = "scene.history.cell.transaction_sent".localized
        } else {
            titleLabel.text = "scene.history.cell.transaction_received".localized
        }
        setDate(transactionEvent.date)
        descriptionLabel.text = transactionEvent.memo ?? transactionEvent.destinationAddresses.first?.string ?? "transaction.no_destination_address".localized
        descriptionLabel.textColor = UIColor.Zap.white
        setAmount(transactionEvent.amount)
    }
    
    func setChannelEvent(_ wrapped: DateWrappedChannelEvent) {
        switch wrapped.channelEvent.type {
        case .open:
            titleLabel.text = "scene.history.cell.channel_opened".localized
        case .cooperativeClose, .unknown:
            titleLabel.text = "scene.history.cell.channel_closed".localized
        case .localForceClose:
            titleLabel.text = "scene.history.cell.force_close_channel".localized
        case .remoteForceClose:
            titleLabel.text = "scene.history.cell.remote_force_close_channel".localized
        case .breachClose:
            titleLabel.text = "scene.history.cell.breach_close_channel".localized
        case .fundingCanceled:
            titleLabel.text = "scene.history.cell.close_channel_funding_canceled".localized
        case .abandoned:
            titleLabel.text = "scene.history.cell.channel_abandoned".localized
        }
        
        descriptionLabel.text = wrapped.channelEvent.node.alias ?? wrapped.channelEvent.node.pubKey
        descriptionLabel.textColor = UIColor.Zap.white
        
        setDate(wrapped.date)
        
        if let amount = wrapped.channelEvent.fee, amount > 0 {
            setAmount(-amount)
        } else {
            setAmount(nil)
        }
    }
    
    func setCreateInvoiceEvent(_ createInvoiceEvent: CreateInvoiceEvent) {
        titleLabel.text = "scene.history.cell.invoice_created".localized
        setDate(createInvoiceEvent.date)
        descriptionLabel?.text = createInvoiceEvent.memo ?? createInvoiceEvent.paymentRequest
        descriptionLabel.textColor = UIColor.Zap.gray
        setAmount(createInvoiceEvent.amount, completed: false)
    }
    
    func setFailedPaymentEvent(_ failedPaymentEvent: FailedPaymentEvent, delegate: HistoryCellDelegate) {
        self.failedPaymentEvent = failedPaymentEvent
        self.delegate = delegate
        
        titleLabel.text = String(format: "scene.history.cell.payment_failed".localized, failedPaymentEvent.node.alias ?? failedPaymentEvent.node.pubKey)
        setDate(failedPaymentEvent.date)
        descriptionLabel?.text = failedPaymentEvent.memo ?? failedPaymentEvent.paymentRequest
        descriptionLabel.textColor = UIColor.Zap.gray
        setAmount(-failedPaymentEvent.amount, completed: false)
        addNotificationLabel(type: .error)
        buttonContainer.isHidden = false
        actionButton.setTitle("scene.history.cell.action.try_again".localized, for: .normal)
    }
    
    func setLightningPaymentEvent(_ lightningPaymentEvent: LightningPaymentEvent) {
        func setTitle(formatString: String, fallback: String) {
            if let nodeAlias = lightningPaymentEvent.node?.alias {
                titleLabel.text = String(format: formatString.localized, nodeAlias)
            } else if let nodePubKey = lightningPaymentEvent.node?.pubKey {
                titleLabel.text = String(format: formatString.localized, nodePubKey)
            } else {
                titleLabel.text = fallback.localized
            }
        }
        
        if lightningPaymentEvent.amount < 0 {
            setTitle(formatString: "scene.history.cell.payment_sent_to", fallback: "scene.history.cell.payment_sent")
        } else {
            setTitle(formatString: "scene.history.cell.payment_received_from", fallback: "scene.history.cell.payment_received")
        }
        
        setDate(lightningPaymentEvent.date)
        setAmount(lightningPaymentEvent.amount, completed: true)
        descriptionLabel?.text = lightningPaymentEvent.memo ?? lightningPaymentEvent.paymentHash
    }
    
    @IBAction private func actionButtonTapped(_ sender: Any) {
        if let failedPaymentEvent = failedPaymentEvent {
            delegate?.resendFailedPayment(failedPaymentEvent)
        }
    }
}
