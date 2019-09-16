//
//  Lightning
//
//  Created by Otto Suess on 12.09.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation
import SwiftBTC
import SwiftLnd

/// Does influence the balance of the user's wallet because a fee is payed.
public struct ChannelEvent: Equatable, DateProvidingEvent {
    public enum Kind: Int {
        case open
        case cooperativeClose
        case localForceClose
        case remoteForceClose
        case breachClose
        case fundingCanceled
        case abandoned

        init(closeType: CloseType) {
            switch closeType {
            case .cooperativeClose:
                self = .cooperativeClose
            case .localForceClose:
                self = .localForceClose
            case .remoteForceClose:
                self = .remoteForceClose
            case .breachClose:
                self = .breachClose
            case .fundingCanceled:
                self = .fundingCanceled
            case .abandoned:
                self = .abandoned
            }
        }
    }

    public let txHash: String
    public let node: LightningNode
    public let type: Kind
    public let fee: Satoshi?
    public let date: Date
}

extension ChannelEvent {
    init?(channel: OpenChannel, dateEstimator: DateEstimator) {
        guard let date = dateEstimator.estimatedDate(forBlockHeight: channel.blockHeight) else { return nil }

        self.date = date

        txHash = channel.channelPoint.fundingTxid
        node = LightningNode(pubKey: channel.remotePubKey, alias: nil, color: nil)

        type = .open
        fee = nil
    }

    init?(pendingChannel: PendingChannel, transaction: Transaction) {
        date = transaction.date

        txHash = pendingChannel.channelPoint.fundingTxid
        node = LightningNode(pubKey: pendingChannel.remotePubKey, alias: nil, color: nil)
        type = .open
        fee = nil
    }

    init?(closing channelCloseSummary: ChannelCloseSummary, dateEstimator: DateEstimator) {
        guard let date = dateEstimator.estimatedDate(forBlockHeight: channelCloseSummary.closeHeight) else { return nil }

        txHash = channelCloseSummary.closingTxHash
        node = LightningNode(pubKey: channelCloseSummary.remotePubKey, alias: nil, color: nil)
        type = ChannelEvent.Kind(closeType: channelCloseSummary.closeType)
        fee = nil
        self.date = date
    }

    init?(opening channelCloseSummary: ChannelCloseSummary, dateEstimator: DateEstimator) {
        guard let date = dateEstimator.estimatedDate(forBlockHeight: channelCloseSummary.openHeight) else { return nil }

        txHash = channelCloseSummary.channelPoint.fundingTxid
        node = LightningNode(pubKey: channelCloseSummary.remotePubKey, alias: nil, color: nil)
        type = .open
        fee = nil
        self.date = date
    }
}
