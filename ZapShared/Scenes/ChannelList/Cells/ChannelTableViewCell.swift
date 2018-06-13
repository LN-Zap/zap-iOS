//
//  Zap
//
//  Created by Otto Suess on 22.01.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import Bond
import UIKit

final class ChannelTableViewCell: BondTableViewCell {
    
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var stateLabel: UILabel!
    @IBOutlet private weak var channelBalanceLabel: UILabel!
    
    var channelViewModel: ChannelViewModel? {
        didSet {
            guard let channelViewModel = channelViewModel else { return }
            
            channelViewModel.name
                .bind(to: nameLabel.reactive.text)
                .dispose(in: onReuseBag)
            
            channelViewModel.state
                .observeNext { [stateLabel] state in
                    stateLabel?.setChannelState(state)
                }
                .dispose(in: onReuseBag)
            
            channelViewModel.channel.localBalance
                .bind(to: channelBalanceLabel.reactive.text, currency: Settings.shared.primaryCurrency)
                .dispose(in: onReuseBag)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        Style.label.apply(to: nameLabel, stateLabel, channelBalanceLabel) {
            $0.font = $0.font.withSize(14)
        }
        stateLabel?.font = stateLabel?.font.withSize(12)
    }
}
