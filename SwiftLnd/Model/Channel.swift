//
//  Zap
//
//  Created by Otto Suess on 21.01.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import Foundation
import SwiftBTC

public struct Channel: Equatable {
    public enum State {
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

    public let blockHeight: Int?
    public let state: State
    public let localBalance: Satoshi
    public let remoteBalance: Satoshi
    public let remotePubKey: String
    public let capacity: Satoshi
    public let updateCount: Int?
    public let channelPoint: ChannelPoint
    public let closingTxid: String?
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
            closingTxid: nil,
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
            closingTxid: nil,
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
            closingTxid: closingTxid,
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
            closingTxid: closingTxid,
            csvDelay: Int(blocksTilMaturity))
    }
}

extension Lnrpc_PendingChannelsResponse.WaitingCloseChannel {
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
                closingTxid: nil,
                csvDelay: 144)
    }
}
