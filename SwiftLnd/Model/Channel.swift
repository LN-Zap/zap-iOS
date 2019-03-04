//
//  Zap
//
//  Created by Otto Suess on 21.01.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import Foundation
import LndRpc
import SwiftBTC

public enum ChannelState {
    case active
    case inactive
    case opening
    case closing
    case forceClosing
    case waitingClose

    public var isClosing: Bool {
        switch self {
        case .closing, .forceClosing, .waitingClose:
            return true
        default:
           return false
        }
    }
}

public struct Channel: Equatable {
    public let blockHeight: Int?
    public let state: ChannelState
    public let localBalance: Satoshi
    public let remoteBalance: Satoshi
    public let remotePubKey: String
    public let capacity: Satoshi
    public let updateCount: Int?
    public let channelPoint: ChannelPoint
    public let csvDelay: Int
}

extension LNDChannel {
    var channelModel: Channel {
        return Channel(
            blockHeight: Int(chanId >> 40),
            state: active ? .active : .inactive,
            localBalance: Satoshi(localBalance),
            remoteBalance: Satoshi(remoteBalance),
            remotePubKey: remotePubkey,
            capacity: Satoshi(capacity),
            updateCount: Int(numUpdates),
            channelPoint: ChannelPoint(string: channelPoint),
            csvDelay: Int(csvDelay))
    }
}

extension LNDPendingChannelsResponse {
    var channels: [Channel] {
        // swiftlint:disable force_cast
        let pendingOpenChannels: [Channel] = pendingOpenChannelsArray.compactMap { ($0 as! LNDPendingChannelsResponse_PendingOpenChannel).channelModel }
        let pendingClosingChannels: [Channel] = pendingClosingChannelsArray.compactMap { ($0 as! LNDPendingChannelsResponse_ClosedChannel).channelModel }
        let pendingForceClosingChannels: [Channel] = pendingForceClosingChannelsArray.compactMap { ($0 as! LNDPendingChannelsResponse_ForceClosedChannel).channelModel }
        let waitingCloseChannels: [Channel] = waitingCloseChannelsArray.compactMap { ($0 as! LNDPendingChannelsResponse_WaitingCloseChannel).channelModel }
        return pendingOpenChannels + pendingClosingChannels + pendingForceClosingChannels + waitingCloseChannels
    }
}

extension LNDPendingChannelsResponse_PendingOpenChannel {
    var channelModel: Channel {
        return Channel(
            blockHeight: nil,
            state: .opening,
            localBalance: Satoshi(channel.localBalance),
            remoteBalance: Satoshi(channel.remoteBalance),
            remotePubKey: channel.remoteNodePub,
            capacity: Satoshi(channel.capacity),
            updateCount: 0,
            channelPoint: ChannelPoint(string: channel.channelPoint),
            csvDelay: 0)
    }
}

extension LNDPendingChannelsResponse_ClosedChannel {
    var channelModel: Channel {
        return Channel(
            blockHeight: nil,
            state: .closing,
            localBalance: Satoshi(channel.localBalance),
            remoteBalance: Satoshi(channel.remoteBalance),
            remotePubKey: channel.remoteNodePub,
            capacity: Satoshi(channel.capacity),
            updateCount: 0,
            channelPoint: ChannelPoint(string: channel.channelPoint),
            csvDelay: 0)
    }
}

extension LNDPendingChannelsResponse_ForceClosedChannel {
    var channelModel: Channel {
        return Channel(
            blockHeight: nil,
            state: .forceClosing,
            localBalance: Satoshi(channel.localBalance),
            remoteBalance: Satoshi(channel.remoteBalance),
            remotePubKey: channel.remoteNodePub,
            capacity: Satoshi(channel.capacity),
            updateCount: 0,
            channelPoint: ChannelPoint(string: channel.channelPoint),
            csvDelay: Int(blocksTilMaturity))
    }
}

extension LNDPendingChannelsResponse_WaitingCloseChannel {
    var channelModel: Channel {
        return Channel(
                blockHeight: nil,
                state: .waitingClose,
                localBalance: Satoshi(channel.localBalance),
                remoteBalance: Satoshi(channel.remoteBalance),
                remotePubKey: channel.remoteNodePub,
                capacity: Satoshi(channel.capacity),
                updateCount: 0,
                channelPoint: ChannelPoint(string: channel.channelPoint),
                csvDelay: 144)
    }
}
