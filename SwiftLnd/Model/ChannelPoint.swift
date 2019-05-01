//
//  Lightning
//
//  Created by Otto Suess on 30.06.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation

public struct ChannelPoint: Equatable {
    public let fundingTxid: String
    let outputIndex: Int

    init(channelPoint: Lnrpc_ChannelPoint) {
        outputIndex = Int(channelPoint.outputIndex)
        fundingTxid = channelPoint.fundingTxidStr
    }

    init(string: String) {
        let parts = string.components(separatedBy: ":")
        fundingTxid = parts[0]
        outputIndex = Int(parts[1]) ?? 0
    }
}
