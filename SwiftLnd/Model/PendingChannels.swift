//
//  SwiftLnd
//
//  Created by 0 on 07.08.19.
//  Copyright © 2019 Zap. All rights reserved.
//

import Foundation
import SwiftBTC

public struct PendingChannels {
    public let forceCloseLimboBalance: Satoshi
    public let channels: [Channel]
}

extension PendingChannels {
    init(pendingChannels: Lnrpc_PendingChannelsResponse) {
        forceCloseLimboBalance = Satoshi(pendingChannels.pendingForceClosingChannels.reduce(0, { $0 + $1.limboBalance }))

        let pendingOpenChannels: [Channel] = pendingChannels.pendingOpenChannels.compactMap(OpeningChannel.init)
        let pendingClosingChannels: [Channel] = pendingChannels.pendingClosingChannels.compactMap(ClosingChannel.init)
        let pendingForceClosingChannels: [Channel] = pendingChannels.pendingForceClosingChannels.compactMap(ForceClosingChannel.init)
        let waitingCloseChannels: [Channel] = pendingChannels.waitingCloseChannels.compactMap(WaitingCloseChannel.init)
        channels = pendingOpenChannels + pendingClosingChannels + pendingForceClosingChannels + waitingCloseChannels
    }
}
