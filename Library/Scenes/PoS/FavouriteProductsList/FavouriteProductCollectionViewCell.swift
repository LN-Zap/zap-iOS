//
//  Library
//
//  Created by Otto Suess on 20.12.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Bond
import UIKit

class FavouriteProductCollectionViewCell: BondCollectionViewCell, ProductCell {
    var count: Observable<Int>? {
        didSet {
            guard let count = count else { return }
            count
                .map { $0 > 0 ? UIColor.Zap.lightningOrange.cgColor : UIColor.Zap.slateBlue.cgColor }
                .observeNext { [weak self] in
                    self?.backgroundBorderView.layer.borderColor = $0
                }
                .dispose(in: onReuseBag)
        }
    }
    
    // swiftlint:disable private_outlet
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    // swiftlint:enable private_outlet
    
    @IBOutlet private weak var separatorView: LineView!
    @IBOutlet private weak var backgroundBorderView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        clipsToBounds = false
        
        Style.Label.body.apply(to: countLabel)
        Style.Label.headline.apply(to: nameLabel)
        Style.Label.subHeadline.apply(to: priceLabel)

        countLabel.clipsToBounds = true
        countLabel.layer.cornerRadius = 12
        countLabel.backgroundColor = UIColor.Zap.lightningOrange
        countLabel.textAlignment = .center
        countLabel.font = UIFont.Zap.posCountFont
        
        backgroundBorderView.layer.cornerRadius = 10
        backgroundBorderView.layer.borderWidth = 1
        backgroundBorderView.layer.borderColor = UIColor.Zap.gray.cgColor
        
        nameLabel.font = UIFont.Zap.bold.withSize(17)
        
        separatorView.layer.cornerRadius = 1
    }
    
    func animateSelection() {
        backgroundBorderView.backgroundColor = .white
        UIView.animate(withDuration: 0.3, delay: 0, options: [.allowUserInteraction, .curveEaseOut], animations: {
            self.backgroundBorderView.backgroundColor = UIColor.Zap.background
        }, completion: nil)
    }
}
