//
//  Library
//
//  Created by Otto Suess on 20.12.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import UIKit

class ShoppingListTableViewCell: UITableViewCell {
    @IBOutlet private weak var amountLabel: UILabel!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var priceLabel: UILabel!
    
    var selectedItem: SelectedItem? {
        didSet {
            guard let selectedItem = selectedItem else { return }
            titleLabel.text = selectedItem.product.name
            amountLabel.text = String(selectedItem.count) + "x"
            priceLabel.text = "\(selectedItem.sum)"
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = UIColor.Zap.background
        Style.Label.body.apply(to: [amountLabel, titleLabel, priceLabel])
    }
}
