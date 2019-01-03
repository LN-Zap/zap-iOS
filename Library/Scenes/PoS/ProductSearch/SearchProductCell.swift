//
//  Library
//
//  Created by Otto Suess on 22.12.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Bond
import UIKit

class SearchProductCell: BondTableViewCell, ProductCell {
    var count: Observable<Int>? {
        didSet {
            guard let count = count else { return }
            count
                .map { $0 <= 0 }
                .bind(to: countContainerView.reactive.isHidden)
                .dispose(in: onReuseBag)
        }
    }
    
    @IBOutlet private weak var countContainerView: UIView!
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
        countLabel.font = UIFont.Zap.posCountFont
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        countLabel.backgroundColor = UIColor.Zap.lightningOrange
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        countLabel.backgroundColor = UIColor.Zap.lightningOrange
    }
}
