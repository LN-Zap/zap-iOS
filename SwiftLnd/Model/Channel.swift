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

public protocol ClosingChannelType {
    var closingTxid: String { get }
}

// Open Channel

public struct OpenChannel: Channel, Equatable {
    public let blockHeight: Int
    public let state: ChannelState
    public let localBalance: Satoshi
    public let remoteBalance: Satoshi
    public let remotePubKey: String
    public let capacity: Satoshi
    public let updateCount: Int
    public let channelPoint: ChannelPoint
    public let csvDelay: Int
}

extension OpenChannel {
    init(openChannel: Lnrpc_Channel) {
        blockHeight = Int(openChannel.chanID >> 40)
        state = openChannel.active ? .active : .inactive
        localBalance = Satoshi(openChannel.localBalance)
        remoteBalance = Satoshi(openChannel.remoteBalance)
        remotePubKey = openChannel.remotePubkey
        capacity = Satoshi(openChannel.capacity)
        updateCount = Int(openChannel.numUpdates)
        channelPoint = ChannelPoint(string: openChannel.channelPoint)
        csvDelay = Int(openChannel.csvDelay)
    }
}

// WaitingCloseChannel

public struct WaitingCloseChannel: Channel, Equatable {
    public let state: ChannelState
    public let localBalance: Satoshi
    public let remoteBalance: Satoshi
    public let remotePubKey: String
    public let capacity: Satoshi
    public let channelPoint: ChannelPoint
}

extension WaitingCloseChannel {
    init(waitingCloseChannel: Lnrpc_PendingChannelsResponse.WaitingCloseChannel) {
        state = .waitingClose
        localBalance = Satoshi(waitingCloseChannel.channel.localBalance)
        remoteBalance = Satoshi(waitingCloseChannel.channel.remoteBalance)
        remotePubKey = waitingCloseChannel.channel.remoteNodePub
        capacity = Satoshi(waitingCloseChannel.channel.capacity)
        channelPoint = ChannelPoint(string: waitingCloseChannel.channel.channelPoint)
    }
}

// ClosingChannel

public struct ClosingChannel: Channel, ClosingChannelType, Equatable {
    public let state: ChannelState
    public let localBalance: Satoshi
    public let remoteBalance: Satoshi
    public let remotePubKey: String
    public let capacity: Satoshi
    public let channelPoint: ChannelPoint
    public let closingTxid: String
}

extension ClosingChannel {
    init(closedChannel: Lnrpc_PendingChannelsResponse.ClosedChannel) {
        state = .closing
        localBalance = Satoshi(closedChannel.channel.localBalance)
        remoteBalance = Satoshi(closedChannel.channel.remoteBalance)
        remotePubKey = closedChannel.channel.remoteNodePub
        capacity = Satoshi(closedChannel.channel.capacity)
        channelPoint = ChannelPoint(string: closedChannel.channel.channelPoint)
        closingTxid = closedChannel.closingTxid
    }
}

// OpeningChannel

public struct OpeningChannel: Channel, Equatable {
    public let state: ChannelState
    public let localBalance: Satoshi
    public let remoteBalance: Satoshi
    public let remotePubKey: String
    public let capacity: Satoshi
    public let channelPoint: ChannelPoint
}

extension OpeningChannel {
    init(pendingOpenChannel: Lnrpc_PendingChannelsResponse.PendingOpenChannel) {
        state = .opening
        localBalance = Satoshi(pendingOpenChannel.channel.localBalance)
        remoteBalance = Satoshi(pendingOpenChannel.channel.remoteBalance)
        remotePubKey = pendingOpenChannel.channel.remoteNodePub
        capacity = Satoshi(pendingOpenChannel.channel.capacity)
        channelPoint = ChannelPoint(string: pendingOpenChannel.channel.channelPoint)
    }
}

// ForceClosingChannel

public struct ForceClosingChannel: Channel, ClosingChannelType, Equatable {
    public let state: ChannelState
    public let localBalance: Satoshi
    public let remoteBalance: Satoshi
    public let remotePubKey: String
    public let capacity: Satoshi
    public let channelPoint: ChannelPoint
    public let closingTxid: String
    public let blocksTilMaturity: Int
}

extension ForceClosingChannel {
    init(forceClosedChannel: Lnrpc_PendingChannelsResponse.ForceClosedChannel) {
        state = .forceClosing
        localBalance = Satoshi(forceClosedChannel.channel.localBalance)
        remoteBalance = Satoshi(forceClosedChannel.channel.remoteBalance)
        remotePubKey = forceClosedChannel.channel.remoteNodePub
        capacity = Satoshi(forceClosedChannel.channel.capacity)
        channelPoint = ChannelPoint(string: forceClosedChannel.channel.channelPoint)
        closingTxid = forceClosedChannel.closingTxid
        blocksTilMaturity = Int(forceClosedChannel.blocksTilMaturity)
    }
}
