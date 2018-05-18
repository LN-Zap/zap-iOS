//
//  Zap
//
//  Created by Otto Suess on 21.01.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import UIKit

class OnChainTransactionTableViewCell: BondTableViewCell {
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var primaryAmountLabel: UILabel!
    @IBOutlet private weak var secondaryAmountLabel: UILabel!
    @IBOutlet private weak var timeLabel: UILabel!
    
    var onChainTransaction: OnChainTransactionViewModel? {
        didSet {
            guard let transaction = onChainTransaction else { return }
            
            [transaction.displayText.bind(to: titleLabel.reactive.text),
             transaction.amount.bind(to: primaryAmountLabel.reactive.text, currency: Settings.primaryCurrency),
             transaction.amount.bind(to: secondaryAmountLabel.reactive.text, currency: Settings.secondaryCurrency)]
                .dispose(in: onReuseBag)
            
            timeLabel.text = transaction.time
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        Style.label.apply(to: primaryAmountLabel, titleLabel) {
            $0.font = $0.font.withSize(14)
        }
        
        Style.label.apply(to: secondaryAmountLabel, timeLabel) {
            $0.font = $0.font.withSize(12)
            $0.textColor = .lightGray
        }
    }
}
