//
//  Lightning
//
//  Created by Otto Suess on 07.07.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation
import LndRpc

public enum CloseType: String, Codable {
    case cooperativeClose
    case localForceClose
    case remoteForceClose
    case breachClose
    case fundingCanceled
    case unknown
    case abandoned
    
    init(closeType: LNDChannelCloseSummary_ClosureType) {
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
        case .gpbUnrecognizedEnumeratorValue:
            self = .unknown
        }
    }
}

public struct ChannelCloseSummary {
    public let closingTxHash: String
    public let channelPoint: ChannelPoint
    public let remotePubKey: String
    public let closeType: CloseType
    public let closeHeight: Int
    public let openHeight: Int
    
    init(channelCloseSummary: LNDChannelCloseSummary) {
        closingTxHash = channelCloseSummary.closingTxHash
        channelPoint = ChannelPoint(string: channelCloseSummary.channelPoint)
        remotePubKey = channelCloseSummary.remotePubkey
        closeType = CloseType(closeType: channelCloseSummary.closeType)
        closeHeight = Int(channelCloseSummary.closeHeight)
        openHeight = Int(channelCloseSummary.chanId >> 40)
    }
}
