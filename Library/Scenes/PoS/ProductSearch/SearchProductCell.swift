//
//  Library
//
//  Created by Otto Suess on 22.12.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import UIKit

class SearchProductCell: BondTableViewCell, ProductCell {
    // swiftlint:disable private_outlet
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    // swiftlint:enable private_outlet
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        Style.Label.body.apply(to: [countLabel, nameLabel, priceLabel])
        backgroundColor = UIColor.Zap.background
        
        countLabel.layer.cornerRadius = 11
        countLabel.clipsToBounds = true
        countLabel.backgroundColor = UIColor.Zap.lightningOrange
    }
}
