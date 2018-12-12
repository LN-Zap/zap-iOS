//
//  Zap
//
//  Created by Otto Suess on 21.01.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import Foundation
import LndRpc
import SwiftProtobuf

enum OpenStatusUpdate {
    case pending
    case confirmation
    case channelOpen
    
    init(_ openStatusUpdate: LNDOpenStatusUpdate) {
        if openStatusUpdate.chanPending.txid != SwiftProtobuf.Internal.emptyData {
            self = .pending
        } else if openStatusUpdate.confirmation.blockSha != SwiftProtobuf.Internal.emptyData {
            self = .confirmation
        } else {
            self = .channelOpen
        }
    }
}
