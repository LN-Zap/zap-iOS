//
//  Library
//
//  Created by Otto Suess on 20.12.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Bond
import UIKit

class ShoppingListTableViewCell: UITableViewCell {
    @IBOutlet private weak var amountLabel: UILabel!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var priceLabel: UILabel!
    
    var selectedItem: (Product, Observable<Int>)? {
        didSet {
            guard let (product, count) = selectedItem else { return }
            titleLabel.text = product.name
            amountLabel.text = String(count.value) + " x"
            priceLabel.text = "\(product.price * Decimal(count.value))"
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = UIColor.Zap.background
        Style.Label.body.apply(to: [amountLabel, titleLabel, priceLabel])
    }
}
