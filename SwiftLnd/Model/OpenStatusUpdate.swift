//
//  Zap
//
//  Created by Otto Suess on 21.01.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import Foundation
import LndRpc

enum OpenStatusUpdate {
    case pending
    case channelOpen

    init(_ openStatusUpdate: LNDOpenStatusUpdate) {
        if openStatusUpdate.chanPending.txid != nil {
            self = .pending
        } else {
            self = .channelOpen
        }
    }
}
