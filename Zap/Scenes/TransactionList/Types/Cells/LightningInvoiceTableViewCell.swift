//
//  Zap
//
//  Created by Otto Suess on 14.05.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import UIKit

class LightningInvoiceTableViewCell: BondTableViewCell {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var primaryAmountLabel: UILabel!
    @IBOutlet private weak var secondaryAmountLabel: UILabel!
    @IBOutlet private weak var timeLabel: UILabel!

    var invoice: LightningInvoiceViewModel? {
        didSet {
            guard let transaction = invoice else { return }
            
            titleLabel.text = transaction.displayText
            
            [Settings.primaryCurrency
                .map { $0.format(satoshis: transaction.amount ) }
                .bind(to: primaryAmountLabel.reactive.text),
             Settings.secondaryCurrency
                .map { $0.format(satoshis: transaction.amount ) }
                .bind(to: secondaryAmountLabel.reactive.text)]
                .dispose(in: reactive.bag)
            
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
