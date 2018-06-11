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
             isPositive.map({ $0 ? UIColor.zap.nastyGreen : UIColor.zap.black }).bind(to: primaryAmountLabel.reactive.textColor),
             transactionViewModel.icon.map({ $0.image }).bind(to: iconImageView.reactive.image),
             transactionViewModel.displayText.bind(to: titleLabel.reactive.text),
             transactionViewModel.amount.bind(to: primaryAmountLabel.reactive.text, currency: Settings.primaryCurrency),
             transactionViewModel.amount
                .map { $0?.absoluteValue() }
                .bind(to: secondaryAmountLabel.reactive.text, currency: Settings.secondaryCurrency)]
                .dispose(in: onReuseBag)
    
            timeLabel.text = DateFormatter.localizedString(from: transactionViewModel.date, dateStyle: .none, timeStyle: .short)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        iconImageView.tintColor = UIColor.zap.black
        
        Style.label.apply(to: primaryAmountLabel, titleLabel) {
            $0.font = $0.font.withSize(14)
        }
        
        Style.label.apply(to: secondaryAmountLabel, timeLabel) {
            $0.font = $0.font.withSize(12)
            $0.textColor = .lightGray
        }
    }
}
