//
//  Library
//
//  Created by Otto Suess on 20.12.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Bond
import UIKit

class ProductCollectionViewCell: BondCollectionViewCell {
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var priceLabel: UILabel!
    @IBOutlet private weak var countLabel: UILabel!
    
    var item: (Product, Observable<Int>)? {
        didSet {
            guard let (product, count) = item else { return }
            
            nameLabel.text = product.name
            priceLabel.text = "\(product.price)"
            
            count
                .map { $0 <= 0 }
                .bind(to: countLabel.reactive.isHidden)
                .dispose(in: onReuseBag)
            
            count
                .map { String($0) }
                .bind(to: countLabel.reactive.text)
                .dispose(in: onReuseBag)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()

        countLabel.clipsToBounds = true
        countLabel.layer.cornerRadius = 11
        countLabel.backgroundColor = UIColor.Zap.lightningOrange
        countLabel.textAlignment = .center
        
        layer.cornerRadius = 10
        layer.borderWidth = 1
        layer.borderColor = UIColor.Zap.gray.cgColor
        
        Style.Label.headline.apply(to: nameLabel)
        Style.Label.subHeadline.apply(to: priceLabel)
        Style.Label.body.apply(to: countLabel)
    }
    
    func animateSelection() {        
        backgroundColor = UIColor.Zap.lightningOrange
        UIView.animate(withDuration: 0.3, delay: 0, options: [.allowUserInteraction], animations: {
            self.backgroundColor = UIColor.Zap.background
        }, completion: nil)
    }
}
