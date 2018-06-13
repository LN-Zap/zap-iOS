//
//  Zap
//
//  Created by Otto Suess on 23.01.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import BTCUtil
import Foundation

extension UILabel {
    func setChannelState(_ state: ChannelState) {
        switch state {
        case .active:
            text = "channel.state.active".localized
        case .inactive:
            text = "channel.state.inactive".localized
        case .opening:
            text = "channel.state.opening".localized
        case .closing:
            text = "channel.state.closing".localized
        case .forceClosing:
            text = "channel.state.force_closing".localized
        }
        
        switch state {
        case .active, .opening:
            textColor = UIColor.zap.nastyGreen
        default:
            textColor = UIColor.zap.lightGrey
        }
    }
    
    func setAmount(_ amount: Satoshi) {
        let result = NSMutableAttributedString()
        
        if amount >= 0 {
            result.append(NSAttributedString(string: "+ ", attributes: [NSAttributedStringKey.foregroundColor: UIColor.zap.nastyGreen]))
        } else {
            result.append(NSAttributedString(string: "- ", attributes: [NSAttributedStringKey.foregroundColor: UIColor.zap.tomato]))
        }
        
        let string = amount.absoluteValue().format(unit: .bit) + " " + BitcoinUnit.bit.localized
        
        result.append(NSAttributedString(string: string))
        
        attributedText = result
    }
}
