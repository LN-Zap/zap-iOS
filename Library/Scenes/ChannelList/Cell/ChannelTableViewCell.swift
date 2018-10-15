//
//  Library
//
//  Created by Otto Suess on 15.10.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import UIKit

class ChannelTableViewCell: BondTableViewCell {

    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var amountLabel: UILabel!
    
    var channelViewModel: ChannelViewModel? {
        didSet {
            nameLabel.text = channelViewModel?.name.value
            
            if channelViewModel?.channel.state == .active {
                channelViewModel?.channel.localBalance
                    .bind(to: amountLabel.reactive.text, currency: Settings.shared.primaryCurrency)
                    .dispose(in: onReuseBag)
            } else {
                amountLabel.text = channelViewModel?.channel.state.localized
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = UIColor.Zap.deepSeaBlue
        
        Style.Label.headline.apply(to: nameLabel)
        Style.Label.body.apply(to: amountLabel)
    }
}
