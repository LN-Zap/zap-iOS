//
//  Zap
//
//  Created by Otto Suess on 23.01.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import BTCUtil
import Foundation
import Lightning

extension UILabel {
    func setAmount(_ amount: Satoshi) {
        let result = NSMutableAttributedString()
        
        if amount >= 0 {
            result.append(NSAttributedString(string: "+ ", attributes: [.foregroundColor: UIColor.zap.nastyGreen]))
        } else {
            result.append(NSAttributedString(string: "- ", attributes: [.foregroundColor: UIColor.zap.tomato]))
        }
        
        let string = amount.absoluteValue().format(unit: .bit) + " " + BitcoinUnit.bit.localized
        
        result.append(NSAttributedString(string: string))
        
        attributedText = result
    }
}
