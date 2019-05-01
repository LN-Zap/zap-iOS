//
//  Zap
//
//  Created by Otto Suess on 21.01.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import Foundation

enum OpenStatusUpdate {
    case pending
    case channelOpen

    init?(_ openStatusUpdate: Lnrpc_OpenStatusUpdate) {
        guard let update = openStatusUpdate.update else { return nil }

        switch update {
        case .chanPending:
            self = .pending
        case .chanOpen:
            self = .channelOpen
        }
    }
}
