//
//  Zap
//
//  Created by Otto Suess on 23.01.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import Bond
import BTCUtil
import UIKit

class PaymentTableViewCell: BondTableViewCell {
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var amountLabel: UILabel!
    
    var payment: Transaction? {
        didSet {
            guard let payment = payment else { return }
            
            nameLabel.text = "Yalls.org"
            
            payment.amount
                .bind(to: amountLabel.reactive.text, currency: Settings.primaryCurrency)
                .dispose(in: onReuseBag)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        Style.label.apply(to: amountLabel, nameLabel)
    }
}
