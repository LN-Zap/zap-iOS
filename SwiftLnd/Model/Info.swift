//
//  Zap
//
//  Created by Otto Suess on 27.01.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import Foundation
import LndRpc
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
    public let version: String
}

extension Info {
    init(getInfoResponse: LNDGetInfoResponse) {
        alias = getInfoResponse.alias
        blockHeight = Int(getInfoResponse.blockHeight)
        isSyncedToChain = getInfoResponse.syncedToChain

        if
            let chains = getInfoResponse.chainsArray as? [LNDChain],
            let networkString = chains.first?.network,
            let network = Network(rawValue: networkString) {
            self.network = network
        } else {
            self.network = getInfoResponse.testnet ? .testnet : .mainnet
        }

        pubKey = getInfoResponse.identityPubkey
        activeChannelCount = Int(getInfoResponse.numActiveChannels)
        bestHeaderDate = Date(timeIntervalSince1970: TimeInterval(getInfoResponse.bestHeaderTimestamp))
        uris = getInfoResponse.urisArray.compactMap {
            guard let string = $0 as? String else { return nil }
            return URL(string: string)
        }
        version = getInfoResponse.version
    }
}
