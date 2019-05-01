//
//  SwiftLnd
//
//  Created by 0 on 03.04.19.
//  Copyright © 2019 Zap. All rights reserved.
//

import Foundation
import Logger

public enum ChannelEventUpdate {
    case open(Channel)
    case closed(ChannelCloseSummary)
    case active(ChannelPoint)
    case inactive(ChannelPoint)

    init?(channelEventUpdate: Lnrpc_ChannelEventUpdate) {
        switch channelEventUpdate.type {
        case .openChannel:
            self = .open(channelEventUpdate.openChannel.channelModel)
        case .closedChannel:
            guard let summary = ChannelCloseSummary(channelCloseSummary: channelEventUpdate.closedChannel) else { return nil }
            self = .closed(summary)
        case .activeChannel:
            self = .active(ChannelPoint(channelPoint: channelEventUpdate.activeChannel))
        case .inactiveChannel:
            self = .inactive(ChannelPoint(channelPoint: channelEventUpdate.inactiveChannel))
        case .UNRECOGNIZED:
            Logger.warn(".UNRECOGNIZED")
            return nil
        }
    }
}
