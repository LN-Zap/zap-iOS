//
//  Zap
//
//  Created by Otto Suess on 27.01.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import Foundation
import SwiftBTC

public struct Info {
    public let alias: String
    public let blockHeight: Int
    public let isSyncedToChain: Bool
    public let network: Network
    public let pubKey: String
    public let activeChannelCount: Int
    public let bestHeaderDate: Date
    public let uris: [URL]
}

extension Info {
    init(getInfoResponse: Lnrpc_GetInfoResponse) {
        alias = getInfoResponse.alias
        blockHeight = Int(getInfoResponse.blockHeight)
        isSyncedToChain = getInfoResponse.syncedToChain
        network = getInfoResponse.testnet ? .testnet : .mainnet
        pubKey = getInfoResponse.identityPubkey
        activeChannelCount = Int(getInfoResponse.numActiveChannels)
        bestHeaderDate = Date(timeIntervalSince1970: TimeInterval(getInfoResponse.bestHeaderTimestamp))
        uris = getInfoResponse.uris.compactMap { URL(string: $0) }
    }
}
