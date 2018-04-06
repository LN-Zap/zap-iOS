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
    
    var onChainTransaction: TransactionViewModel? {
        didSet {
            guard let transaction = onChainTransaction else { return }
            
            nameLabel.text = transaction.displayText
            
            transaction.amount
                .bind(to: amountLabel.reactive.text, currency: Settings.primaryCurrency)
                .dispose(in: onReuseBag)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        Style.label.apply(to: amountLabel, nameLabel)
    }
}
