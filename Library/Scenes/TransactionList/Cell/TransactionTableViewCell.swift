//
//  Zap
//
//  Created by Otto Suess on 21.01.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import UIKit

final class TransactionTableViewCell: BondTableViewCell {
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var primaryAmountLabel: UILabel!
    @IBOutlet private weak var secondaryAmountLabel: UILabel!
    @IBOutlet private weak var timeLabel: UILabel!
    @IBOutlet private weak var iconImageView: UIImageView!
    @IBOutlet private weak var positiveAmountBackgroundView: UIView!
    
    var transactionViewModel: TransactionViewModel? {
        didSet {
            guard let transactionViewModel = transactionViewModel else { return }
            
            let isPositive = transactionViewModel.amount
                .map { $0.flatMap { $0 > 0 } ?? false }
            
            [isPositive.map({ !$0 }).bind(to: positiveAmountBackgroundView.reactive.isHidden),
             isPositive.map({ $0 ? UIColor.Zap.black : .white }).bind(to: primaryAmountLabel.reactive.textColor),
             transactionViewModel.icon.map({ $0.image }).bind(to: iconImageView.reactive.image),
             transactionViewModel.displayText.bind(to: titleLabel.reactive.text),
             transactionViewModel.amount.bind(to: primaryAmountLabel.reactive.text, currency: Settings.shared.primaryCurrency),
             transactionViewModel.amount
                .map { $0?.absoluteValue() }
                .bind(to: secondaryAmountLabel.reactive.text, currency: Settings.shared.secondaryCurrency),
             transactionViewModel.annotation
                .map { $0.isHidden ? UIColor.Zap.superRed.withAlphaComponent(0.1) : UIColor.clear }
                .bind(to: reactive.backgroundColor)]
                .dispose(in: onReuseBag)
    
            timeLabel.text = DateFormatter.localizedString(from: transactionViewModel.date, dateStyle: .none, timeStyle: .short)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        iconImageView.tintColor = .white
        
        Style.Label.body.apply(to: primaryAmountLabel, titleLabel)
        Style.Label.subHeadline.apply(to: secondaryAmountLabel, timeLabel)
    }
}
