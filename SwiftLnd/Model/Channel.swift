//
//  Zap
//
//  Created by Otto Suess on 21.01.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import BTCUtil
import Foundation

public enum ChannelState {
    case active
    case inactive
    case opening
    case closing
    case forceClosing
    
    public var isClosing: Bool {
        switch self {
        case .closing, .forceClosing:
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

extension Lnrpc_Channel {
    var channelModel: Channel {
        return Channel(
            blockHeight: Int(chanID >> 40),
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

extension Lnrpc_PendingChannelsResponse.PendingOpenChannel {
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

extension Lnrpc_PendingChannelsResponse.ClosedChannel {
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

extension Lnrpc_PendingChannelsResponse.ForceClosedChannel {
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
