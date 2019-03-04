//
//  Zap
//
//  Created by Otto Suess on 23.01.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import Foundation
import LndRpc

public enum CloseStatusUpdate {
    case pending
    case channelClose

    init(closeStatusUpdate: LNDCloseStatusUpdate) {
        if closeStatusUpdate.closePending.txid != nil {
            self = .pending
        } else {
            self = .channelClose
        }
    }
}
