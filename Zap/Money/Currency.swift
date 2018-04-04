//
//  Zap
//
//  Created by Otto Suess on 31.03.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import BTCUtil
import Foundation

protocol Currency: Localizable {
    var symbol: String { get }
    
    func format(_ satoshis: Satoshi) -> String?
}
