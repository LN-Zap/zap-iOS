//
//  BTCUtil
//
//  Created by Otto Suess on 28.02.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import Foundation

enum Bolt11 {
    static func isValid(_ string: String) -> Bool {
        return Bech32.decode(string, limit: false) != nil
    }
}
