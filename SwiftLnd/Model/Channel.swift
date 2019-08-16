//
//  Zap
//
//  Created by Otto Suess on 21.01.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import Foundation
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

public protocol Channel {
    var state: ChannelState { get }
    var localBalance: Satoshi { get }
    var remoteBalance: Satoshi { get }
    var capacity: Satoshi { get }
    var remotePubKey: String { get }
    var channelPoint: ChannelPoint { get }
}

public struct OpenChannel: Channel, Equatable {
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
    var channelModel: OpenChannel {
        return OpenChannel(
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

// Pending

public protocol PendingChannel: Channel {
    var state: ChannelState { get }
        var localBalance: Satoshi { get }
        var remoteBalance: Satoshi { get }
        var remotePubKey: String { get }
        var capacity: Satoshi { get }
        var channelPoint: ChannelPoint { get }
}

public struct WaitingCloseChannel: PendingChannel, Equatable {
    public let state: ChannelState
    public let localBalance: Satoshi
    public let remoteBalance: Satoshi
    public let remotePubKey: String
    public let capacity: Satoshi
    public let channelPoint: ChannelPoint
}

extension Lnrpc_PendingChannelsResponse.WaitingCloseChannel {
    var channelModel: PendingChannel {
        return WaitingCloseChannel(
            state: .waitingClose,
            localBalance: Satoshi(channel.localBalance),
            remoteBalance: Satoshi(channel.remoteBalance),
            remotePubKey: channel.remoteNodePub,
            capacity: Satoshi(channel.capacity),
            channelPoint: ChannelPoint(string: channel.channelPoint))
    }
}

public struct ClosingChannel: PendingChannel, Equatable {
    public let state: ChannelState
    public let localBalance: Satoshi
    public let remoteBalance: Satoshi
    public let remotePubKey: String
    public let capacity: Satoshi
    public let channelPoint: ChannelPoint
    public let closingTxid: String?
}

extension Lnrpc_PendingChannelsResponse.ClosedChannel {
    var channelModel: PendingChannel {
        return ClosingChannel(
            state: .closing,
            localBalance: Satoshi(channel.localBalance),
            remoteBalance: Satoshi(channel.remoteBalance),
            remotePubKey: channel.remoteNodePub,
            capacity: Satoshi(channel.capacity),
            channelPoint: ChannelPoint(string: channel.channelPoint),
            closingTxid: closingTxid)
    }
}

public struct OpeningChannel: PendingChannel, Equatable {
    public let state: ChannelState
    public let localBalance: Satoshi
    public let remoteBalance: Satoshi
    public let remotePubKey: String
    public let capacity: Satoshi
    public let channelPoint: ChannelPoint
}

extension Lnrpc_PendingChannelsResponse.PendingOpenChannel {
    var channelModel: PendingChannel {
        return OpeningChannel(
            state: .opening,
            localBalance: Satoshi(channel.localBalance),
            remoteBalance: Satoshi(channel.remoteBalance),
            remotePubKey: channel.remoteNodePub,
            capacity: Satoshi(channel.capacity),
            channelPoint: ChannelPoint(string: channel.channelPoint))
    }
}

public struct ForceClosingChannel: PendingChannel, Equatable {
    public let state: ChannelState
    public let localBalance: Satoshi
    public let remoteBalance: Satoshi
    public let remotePubKey: String
    public let capacity: Satoshi
    public let channelPoint: ChannelPoint
    public let closingTxid: String?
    public let blocksTilMaturity: Int
}

extension Lnrpc_PendingChannelsResponse.ForceClosedChannel {
    var channelModel: PendingChannel {
        return ForceClosingChannel(
            state: .forceClosing,
            localBalance: Satoshi(channel.localBalance),
            remoteBalance: Satoshi(channel.remoteBalance),
            remotePubKey: channel.remoteNodePub,
            capacity: Satoshi(channel.capacity),
            channelPoint: ChannelPoint(string: channel.channelPoint),
            closingTxid: closingTxid,
            blocksTilMaturity: Int(blocksTilMaturity))
    }
}
