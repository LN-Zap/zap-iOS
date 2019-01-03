//
//  Library
//
//  Created by Otto Suess on 20.12.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Bond
import UIKit

class FavouriteProductCollectionViewCell: BondCollectionViewCell, ProductCell {
    // swiftlint:disable private_outlet
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    // swiftlint:enable private_outlet
    
    override func awakeFromNib() {
        super.awakeFromNib()

        Style.Label.body.apply(to: countLabel)
        Style.Label.headline.apply(to: nameLabel)
        Style.Label.subHeadline.apply(to: priceLabel)

        countLabel.clipsToBounds = true
        countLabel.layer.cornerRadius = 11
        countLabel.backgroundColor = UIColor.Zap.lightningOrange
        countLabel.textAlignment = .center
        countLabel.font = UIFont.Zap.posCountFont
        
        layer.cornerRadius = 10
        layer.borderWidth = 1
        layer.borderColor = UIColor.Zap.gray.cgColor
    }
    
    func animateSelection() {
        backgroundColor = UIColor.Zap.lightningOrange
        UIView.animate(withDuration: 0.3, delay: 0, options: [.allowUserInteraction], animations: {
            self.backgroundColor = UIColor.Zap.background
        }, completion: nil)
    }
}
