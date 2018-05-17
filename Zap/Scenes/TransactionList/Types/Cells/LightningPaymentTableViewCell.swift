//
//  Zap
//
//  Created by Otto Suess on 23.01.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import Bond
import BTCUtil
import UIKit

class LightningPaymentTableViewCell: BondTableViewCell {
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var amountLabel: UILabel!
    @IBOutlet private weak var timeLabel: UILabel!
    
    var payment: LightningPaymentViewModel? {
        didSet {
            guard let payment = payment else { return }
                        
            [payment.annotation
                .map { $0.customMemo ?? payment.displayText }
                .bind(to: nameLabel.reactive.text),
             Settings.primaryCurrency
                .map { $0.format(satoshis: payment.amount ) }
                .bind(to: amountLabel.reactive.text)]
                .dispose(in: onReuseBag)
            
            timeLabel.text = payment.time
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
