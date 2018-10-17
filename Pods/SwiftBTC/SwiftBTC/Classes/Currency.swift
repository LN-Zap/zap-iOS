//
//  SwiftBTC
//
//  Created by Otto Suess on 31.03.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation

/// Represents currencies like Bitcoin or USD
public protocol Currency {
    var symbol: String { get }
        
    // format satoshis. (1253 -> "$0.10")
    func format(satoshis: Satoshi) -> String?
    
    // string without localization stuff (10025230) -> "100252.3"
    func stringValue(satoshis: Satoshi) -> String?
    
    func satoshis(from: String) -> Satoshi?
    
    func value(satoshis: Satoshi) -> Decimal?
}
