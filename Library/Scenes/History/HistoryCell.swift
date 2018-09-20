//
//  Zap
//
//  Created by Otto Suess on 21.01.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import BTCUtil
import Lightning
import UIKit

final class HistoryCell: BondTableViewCell {
    enum NotificationType {
        case error
        case new
        case pending
        
        var style: (UIColor, String) {
            switch self {
            case .error:
                return (UIColor.Zap.superRed, "error")
            case .new:
                return (UIColor.Zap.purple, "new")
            case .pending:
                return (UIColor.Zap.purple, "pending")
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
            titleLabel.text = "Payment sent"
        } else {
            titleLabel.text = "Payment received"
        }
        setDate(transactionEvent.date)
        descriptionLabel.text = transactionEvent.memo ?? transactionEvent.destinationAddresses.first?.string
        descriptionLabel.textColor = UIColor.Zap.white
        setAmount(transactionEvent.amount)
    }
    
    func setChannelEvent(_ wrapped: DateWrappedChannelEvent) {
        switch wrapped.channelEvent.type {
        case .open:
            titleLabel.text = "Open Channel"
        case .cooperativeClose, .unknown:
            titleLabel.text = "Close Channel"
        case .localForceClose:
            titleLabel.text = "Force close Channel"
        case .remoteForceClose:
            titleLabel.text = "Remote force close Channel"
        case .breachClose:
            titleLabel.text = "Breach close Channel"
        case .fundingCanceled:
            titleLabel.text = "Close Channel (funding canceled)"
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
        titleLabel.text = "Payment Request created"
        setDate(createInvoiceEvent.date)
        descriptionLabel?.text = createInvoiceEvent.memo ?? createInvoiceEvent.paymentRequest
        descriptionLabel.textColor = UIColor.Zap.gray
        setAmount(createInvoiceEvent.amount, completed: false)
    }
    
    func setFailedPaymentEvent(_ failedPaymentEvent: FailedPaymentEvent) {
        titleLabel.text = "Payment did not send"
        setDate(failedPaymentEvent.date)
        descriptionLabel?.text = failedPaymentEvent.memo ?? failedPaymentEvent.paymentRequest
        descriptionLabel.textColor = UIColor.Zap.gray
        setAmount(failedPaymentEvent.amount, completed: false)
        addNotificationLabel(type: .error)
        buttonContainer.isHidden = false
        actionButton.setTitle("Try Again", for: .normal)
    }
    
    func setLightningPaymentEvent(_ lightningPaymentEvent: LightningPaymentEvent) {
        if lightningPaymentEvent.amount < 0 {
            titleLabel.text = "Lightning Payment sent"
        } else {
            titleLabel.text = "Lightning Payment received"
        }
        
        setDate(lightningPaymentEvent.date)
        setAmount(lightningPaymentEvent.amount, completed: true)
        descriptionLabel?.text = lightningPaymentEvent.memo ?? lightningPaymentEvent.paymentHash
    }
}
