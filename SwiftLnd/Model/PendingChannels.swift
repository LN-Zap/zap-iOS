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
    public let channels: [PendingChannel]
}

extension PendingChannels {
    init(pendingChannels: Lnrpc_PendingChannelsResponse) {
        forceCloseLimboBalance = Satoshi(pendingChannels.pendingForceClosingChannels.reduce(0, { $0 + $1.limboBalance }))

        let pendingOpenChannels: [PendingChannel] = pendingChannels.pendingOpenChannels.compactMap { $0.channelModel }
        let pendingClosingChannels: [PendingChannel] = pendingChannels.pendingClosingChannels.compactMap { $0.channelModel }
        let pendingForceClosingChannels: [PendingChannel] = pendingChannels.pendingForceClosingChannels.compactMap { $0.channelModel }
        let waitingCloseChannels: [PendingChannel] = pendingChannels.waitingCloseChannels.compactMap { $0.channelModel }
        channels = pendingOpenChannels + pendingClosingChannels + pendingForceClosingChannels + waitingCloseChannels
    }
}
