//
//  Zap
//
//  Created by Otto Suess on 23.01.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import Foundation

public enum CloseStatusUpdate {
    case pending
    case channelClose

    init?(closeStatusUpdate: Lnrpc_CloseStatusUpdate) {
        guard let update = closeStatusUpdate.update else { return nil }
        switch update {
        case .closePending:
            self = .pending
        case .chanClose:
            self = .channelClose
        }
    }
}
