//
//  Library
//
//  Created by Otto Suess on 20.12.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import UIKit

class ProductCollectionViewCell: UICollectionViewCell {
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var priceLabel: UILabel!
    
    var product: Product? {
        didSet {
            guard let product = product else { return }
            self.nameLabel.text = product.name
            self.priceLabel.text = "\(product.price)"
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()

        layer.cornerRadius = 10
        layer.borderWidth = 1
        layer.borderColor = UIColor.Zap.gray.cgColor
        
        Style.Label.headline.apply(to: nameLabel)
        Style.Label.subHeadline.apply(to: priceLabel)
    }
}
