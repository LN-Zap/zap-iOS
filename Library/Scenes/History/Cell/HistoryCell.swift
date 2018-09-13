//
//  Zap
//
//  Created by Otto Suess on 21.01.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import Lightning
import UIKit

final class HistoryCell: BondTableViewCell {
    
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var amountLabel: UILabel!
    private weak var notificationLabel: PaddingLabel?
    
    func addNotificationLabel() {
        let label = PaddingLabel(frame: CGRect(x: 0, y: 0, width: 100, height: 20))
        label.text = "error"

        Style.Label.footnote.apply(to: label)
        label.textColor = UIColor.Zap.white
        label.edgeInsets = UIEdgeInsets(top: 0, left: 7, bottom: 0, right: 7)
        label.backgroundColor = UIColor.Zap.superRed
        label.layer.cornerRadius = 7
        label.layer.masksToBounds = true

        addAutolayoutSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerYAnchor.constraint(equalTo: containerView.topAnchor),
            containerView.trailingAnchor.constraint(equalTo: label.trailingAnchor, constant: 15),
            label.topAnchor.constraint(equalTo: topAnchor, constant: 10)
        ])
        
        label.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 999), for: .vertical)
        
        notificationLabel = label
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        notificationLabel?.removeFromSuperview()
        notificationLabel = nil
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        containerView.backgroundColor = UIColor.Zap.seaBlue
        containerView.layer.cornerRadius = Appearance.Constants.modalCornerRadius
        
        Style.Label.headline.apply(to: titleLabel)
        Style.Label.body.apply(to: descriptionLabel, amountLabel)
        Style.Label.footnote.apply(to: dateLabel)
        
        addNotificationLabel()
    }
    
    func setTransactionEvent(_ transactionEvent: TransactionEvent) {
        titleLabel.text = "Payment sent"
        dateLabel.text = transactionEvent.date.localized
        descriptionLabel.text = transactionEvent.memo
        amountLabel.text = "12430.12"
    }
}
