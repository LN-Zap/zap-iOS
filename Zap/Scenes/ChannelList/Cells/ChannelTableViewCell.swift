//
//  Zap
//
//  Created by Otto Suess on 22.01.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import Bond
import UIKit

class ChannelTableViewCell: BondTableViewCell {
    
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var stateLabel: UILabel!
    
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
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        Style.label.apply(to: nameLabel, stateLabel)

        nameLabel?.font = nameLabel?.font.withSize(14)
        stateLabel?.font = stateLabel?.font.withSize(12)
    }
}
