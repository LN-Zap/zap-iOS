//
//  Zap
//
//  Created by Otto Suess on 21.01.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import UIKit

class OnChainTransactionTableViewCell: BondTableViewCell {
    
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var amountLabel: UILabel!
    @IBOutlet private weak var timeLabel: UILabel!
    
    var onChainTransaction: TransactionViewModel? {
        didSet {
            guard let transaction = onChainTransaction else { return }
            
            transaction.displayText
                .bind(to: nameLabel.reactive.text)
                .dispose(in: onReuseBag)
            
            transaction.amount
                .bind(to: amountLabel.reactive.text, currency: Settings.primaryCurrency)
                .dispose(in: onReuseBag)
            
            timeLabel.text = transaction.time
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        Style.label.apply(to: amountLabel, nameLabel) {
            $0.font = $0.font.withSize(14)
        }
        timeLabel.font = Font.light.withSize(12)
        timeLabel.textColor = .lightGray
    }
}
