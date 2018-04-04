//
//  Zap
//
//  Created by Otto Suess on 21.01.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import Foundation
import LightningRpc

enum OpenStatusUpdate {
    case pending
    case confirmation
    case channelOpen
    
    init(_ openStatusUpdate: LightningRpc.OpenStatusUpdate) {
        if openStatusUpdate.chanPending != nil {
            self = .pending
        } else if openStatusUpdate.confirmation != nil {
            self = .confirmation
        } else {
            self = .channelOpen
        }
    }
}
