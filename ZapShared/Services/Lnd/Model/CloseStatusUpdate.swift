//
//  Zap
//
//  Created by Otto Suess on 23.01.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import Foundation
import SwiftProtobuf

enum CloseStatusUpdate {
    case pending
    case confirmation
    case channelClose
    
    init(closeStatusUpdate: Lnrpc_CloseStatusUpdate) {
        if closeStatusUpdate.closePending.txid != SwiftProtobuf.Internal.emptyData {
            self = .pending
        } else if closeStatusUpdate.confirmation.blockSha != SwiftProtobuf.Internal.emptyData {
            self = .confirmation
        } else {
            self = .channelClose
        }
    }
}
