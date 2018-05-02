//
//  Zap
//
//  Created by Otto Suess on 23.01.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import Foundation

enum CloseStatusUpdate {
    case pending
    case confirmation
    case channelClose
    
    init(_ closeStatusUpdate: Lnrpc_CloseStatusUpdate) {
        if closeStatusUpdate.closePending != nil {
            self = .pending
        } else if closeStatusUpdate.confirmation != nil {
            self = .confirmation
        } else {
            self = .channelClose
        }
    }
}
