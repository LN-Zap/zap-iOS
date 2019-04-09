//
//  SwiftLnd
//
//  Created by 0 on 03.04.19.
//  Copyright © 2019 Zap. All rights reserved.
//

import Foundation
import LndRpc

public enum ChannelEventUpdate {
    case open(Channel)
    case closed(ChannelCloseSummary)
    case active(ChannelPoint)
    case inactive(ChannelPoint)

    init?(channelEventUpdate: LNDChannelEventUpdate) {
        switch channelEventUpdate.type {
        case .openChannel:
            self = .open(channelEventUpdate.openChannel.channelModel)
        case .closedChannel:
            self = .closed(ChannelCloseSummary(channelCloseSummary: channelEventUpdate.closedChannel))
        case .activeChannel:
            self = .active(ChannelPoint(channelPoint: channelEventUpdate.activeChannel))
        case .inactiveChannel:
            self = .inactive(ChannelPoint(channelPoint: channelEventUpdate.inactiveChannel))
        case .gpbUnrecognizedEnumeratorValue:
            return nil
        @unknown default:
            return nil
        }
    }
}
