//
//  Zap
//
//  Created by Otto Suess on 22.01.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import UIKit

class ChannelTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var stateLabel: UILabel!
    
    var channel: Channel? {
        didSet {
            guard let channel = channel else { return }
            
            nameLabel.text = channel.remotePubKey
            stateLabel.setChannelState(channel.state)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        Style.label.apply(to: nameLabel, stateLabel)

        nameLabel?.font = nameLabel?.font.withSize(14)
        stateLabel?.font = stateLabel?.font.withSize(12)
    }
}
