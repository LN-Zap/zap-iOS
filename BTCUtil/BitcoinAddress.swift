//
//  BTCUtil
//
//  Created by Otto Suess on 28.02.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import Foundation

struct BitcoinAddress {
    enum AddressType: Int {
        case pubkeyHash = 0
        case scriptHash = 5
        case privateKey = 128
        case testnetPubkeyHash = 111
        case testnetScriptHash = 196
        case testnetPrivateKey = 239
    }
    
    let type: AddressType
    let string: String
    
    init?(string: String) {
        guard
            let (version, _) = Base58Check.checkDecode(string),
            let type = AddressType(rawValue: version)
            else { return nil }
        
        self.string = string
        self.type = type
    }
}
