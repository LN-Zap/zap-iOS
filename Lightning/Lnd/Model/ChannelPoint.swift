//
//  Lightning
//
//  Created by Otto Suess on 30.06.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation

public struct ChannelPoint {
    let outputIndex: Int
    let fundingTxid: String
    
    init(channelPoint: Lnrpc_ChannelPoint) {
        outputIndex = Int(channelPoint.outputIndex)
        fundingTxid = channelPoint.fundingTxidStr
    }
}
