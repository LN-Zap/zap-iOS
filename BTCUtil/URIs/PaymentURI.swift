//
//  BTCUtil
//
//  Created by Otto Suess on 06.07.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation

public protocol PaymentURI {
    var address: String { get }
    var network: Network { get }
    var amount: Satoshi? { get }
    var memo: String? { get }
    
    var uriString: String { get }
    var isCaseSensitive: Bool { get }
}
